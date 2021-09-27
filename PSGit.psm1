Import-Module -Name AzurePipelinesPS -RequiredVersion 4.0.7 -Force
Import-Module -Name PowerShellForGitHub -RequiredVersion 0.16.0 -Force

Function Invoke-PSGitLogin {
    <#
    .SYNOPSIS
        Login to target platform

    .PARAMETER Platform
        Target platform

    .PARAMETER Project
        Project

    .PARAMETER GitRepo
        GIT repository name

    .PARAMETER SecureToken
        Secure PAT token

    .PARAMETER Uri
        Uri

	.EXAMPLE
        # Login to Azure DevOps
        $AzDevToken = Read-Host -AsSecureString -Prompt "Give Azure DevOps PAT"
        Invoke-PSGitLogin -Platform "AzureDevOps" -Project "PSGit" -GitRepo "PSGit" -SecureToken $AzDevToken -Uri "https://dev.azure.com/olljanat"

	.EXAMPLE
        # Login to GitHub
        $GitHubToken = Read-Host -AsSecureString -Prompt "Give GitHub PAT"
        Invoke-PSGitLogin -Platform "GitHub" -Project "PSGitLab" -GitRepo "PSGit" -SecureToken $GitHubToken -Uri "https://github.com"
    #>
	param (
		[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][ValidateSet("AzureDevOps","GitHub")][string]$Platform,
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Project,
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$GitRepo,
		[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][SecureString]$SecureToken,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Uri
	)
    $local:PlainTextToken = [System.Net.NetworkCredential]::new("", $SecureToken).Password
    $global:PSGitPlatform = $Platform
	$global:PSGitProject = $Project
	$global:PSGitRepo = $GitRepo
	$global:PSGitUri = $Uri

    switch($Platform) {
        AzureDevOps {
			Get-APSession | Remove-APSession
            $splat = @{
                Collection          = '/'
                Project             = $Project
                Instance            = $Uri
                PersonalAccessToken = $PlainTextToken
                ApiVersion          = '6.1-preview.1'
                SessionName         = "AzSession"
            }
            $global:PSGitAzSession = New-APSession @splat
        }
        GitHub {
			$cred = New-Object System.Management.Automation.PSCredential("-", $SecureToken)
			Set-GitHubAuthentication -Credential $cred -SessionOnly
			Set-GitHubConfiguration -DisableTelemetry -DefaultOwnerName $Project -DefaultRepositoryName $GitRepo
        }
        default {
            Write-Error "Platform $Platform is not supported"
            exit 1
        }
    }
}

Function Get-PSGitRepos {
    <#
    .SYNOPSIS
        Get GIT Repositories

	.EXAMPLE
        Get-PSGitRepos
    #>
	param ()

    $newGitRepos = @()
    switch($PSGitPlatform) {
        AzureDevOps {
            $gitRepos = Get-APRepositoryList -Session $PSGitAzSession
            forEach($repo in $gitRepos) {
                $newGitRepos += New-Object -TypeName PSObject -Property @{
                    "Id" = $repo.id
                    "Name" = $repo.name
                    "Url" = $repo.webUrl
                    "Visibility" = $repo.project.visibility
                    "IsDisable" = $repo.isDisabled
                }
            }
        }
        GitHub {
			$gitRepos = Get-GitHubRepository -OrganizationName $PSGitProject
            forEach($repo in $gitRepos) {
                $newGitRepos += New-Object -TypeName PSObject -Property @{
                    "Id" = $repo.id
                    "Name" = $repo.name
                    "Url" = $repo.RepositoryUrl
                    "Visibility" = $repo.visibility
                    "IsDisable" = $repo.disabled
                }
            }
        }
        default {
            Write-Error "Platform $Platform is not supported"
            exit 1
        }
    }
    $defaultDisplaySet = 'Id','Name', "Url", "Visibility", "IsDisable"
	$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
	$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    $newGitRepos | Add-Member MemberSet PSStandardMembers $PSStandardMembers

    return $newGitRepos
}
