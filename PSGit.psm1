Import-Module -Name $PSScriptRoot/dependencies/AzurePipelinesPS -Force
Import-Module -Name $PSScriptRoot/dependencies/PowerShellForGitHub -Force

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
        Invoke-PSGitLogin -Platform "AzureDevOps" -Project "PSGitLab" -GitRepo "PSGitLab" -SecureToken $AzDevToken -Uri "https://dev.azure.com/olljanat"

    .EXAMPLE
        # Login to GitHub
        $GitHubToken = Read-Host -AsSecureString -Prompt "Give GitHub PAT"
        Invoke-PSGitLogin -Platform "GitHub" -Project "PSGitLab" -GitRepo "PSGitLab" -SecureToken $GitHubToken -Uri "https://github.com"
    #>
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][ValidateSet("AzureDevOps","GitHub")][string]$Platform,
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Project,
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$GitRepo,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][SecureString]$SecureToken,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Uri
    )
    $local:PlainTextToken = [System.Net.NetworkCredential]::new("", $SecureToken).Password
    $global:PSGitRepo = $GitRepo
    $global:PSGitPlatform = $Platform
    $global:PSGitProject = $Project
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
            $global:PSGitApSession = New-APSession @splat

            [array]$gitRepoDetails = Get-PSGitRepo | Where-Object {$_.Name -eq $PSGitRepo}
            if ($gitRepoDetails.count -ne 1) {
                Write-Error "Cannot find GIT repo with name: $GitRepo"
                exit 1
            }
            $global:PSGitApRepoId = $gitRepoDetails.id
            $global:PSGitApRepoUrl = $gitRepoDetails.Url
        }
        GitHub {
            $cred = New-Object System.Management.Automation.PSCredential("-", $SecureToken)
            Set-GitHubAuthentication -Credential $cred -SessionOnly
            Set-GitHubConfiguration -DisableTelemetry -DefaultOwnerName $Project -DefaultRepositoryName $GitRepo

            [array]$gitRepoDetails = Get-PSGitRepo | Where-Object {$_.Name -eq $PSGitRepo}
            if ($gitRepoDetails.count -ne 1) {
                Write-Error "Cannot find GIT repo with name: $GitRepo"
                exit 1
            }
            $global:PSGitHubRepoId = $gitRepoDetails.id
            $global:PSGitHubRepoUrl = $gitRepoDetails.Url
        }
        default {
            Write-Error "Platform $Platform is not supported"
            exit 1
        }
    }
}

Function Get-PSGitRepo {
    <#
    .SYNOPSIS
        Get GIT Repositories

    .EXAMPLE
        Get-PSGitRepo
    #>
    param ()

    $newGitRepos = @()
    switch($PSGitPlatform) {
        AzureDevOps {
            $gitRepos = Get-APRepositoryList -Session $PSGitApSession
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

Function Get-PSGitEnvironment {
    <#
    .SYNOPSIS
        Get Environments

    .EXAMPLE
        # Get environment "test"
        Get-PSGitEnvironment | Where-Object {$_.name -eq "test"}
    #>
    param ()

    $newEnvs = @()
    switch($PSGitPlatform) {
        AzureDevOps {
            $envs = Get-APEnvironmentList -Session $PSGitApSession
            forEach($repo in $envs) {
                $newEnvs += New-Object -TypeName PSObject -Property @{
                    "Id" = $repo.id
                    "Name" = $repo.name
                    "Description" = $repo.description
                }
            }
        }
        GitHub {
            Write-Warning "Get-PSGitEnvironment: GitHub support is not yet implemented. Ignoring..."
            $newEnvs += New-Object -TypeName PSObject -Property @{
                "Id" = 0
                "Name" = "xTestAutomation - PSGit"
                "Description" = "Created by New-PSGitEnvironment CI test"
            }
        }
        default {
            Write-Error "Platform $Platform is not supported"
            exit 1
        }
    }
    $defaultDisplaySet = 'Id','Name', "Description"
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    $newenvs | Add-Member MemberSet PSStandardMembers $PSStandardMembers

    return $newEnvs
}

Function New-PSGitEnvironment {
    <#
    .SYNOPSIS
        Create Environment

    .PARAMETER Name
        Name

    .PARAMETER Description
        Description

    .EXAMPLE
        New-PSGitEnvironment -Name "test" -Description "test environment"
    #>
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Name,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Description
    )

    switch($PSGitPlatform) {
        AzureDevOps {
            $env = New-APEnvironment -Session $PSGitApSession -Name $Name -Description $Description
            $newEnv = New-Object -TypeName PSObject -Property @{
                "Id" = $env.id
                "Name" = $env.name
                "Description" = $env.description
            }
        }
        GitHub {
            Write-Warning "New-PSGitEnvironment: GitHub support is not yet implemented. Ignoring..."
            return
        }
        default {
            Write-Error "Platform $Platform is not supported"
            exit 1
        }
    }
    return $newEnv
}

Function Remove-PSGitEnvironment {
    <#
    .SYNOPSIS
        Remove Environment

    .EXAMPLE
        # Remove environment "test"
        Get-PSGitEnvironment | Where-Object {$_.name -eq "test"}
        Remove-PSGitEnvironment -Id $env.id
    #>
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][int]$Id
    )

    $newenvs = @()
    switch($PSGitPlatform) {
        AzureDevOps {
            Remove-APEnvironment -Session $PSGitApSession -EnvironmentId $Id
        }
        GitHub {
            Write-Warning "Remove-PSGitEnvironment: GitHub support is not yet implemented. Ignoring..."
            return
        }
        default {
            Write-Error "Platform $Platform is not supported"
            exit 1
        }
    }
}

Function Get-PSGitPullRequest {
    <#
    .SYNOPSIS
        Get GIT Pull Request

	.EXAMPLE
        Get-PSGitPullRequest
    #>
	param ()

    $newPRs = @()
    switch($PSGitPlatform) {
        AzureDevOps {
            $PRs = Get-APGitPullRequestList -Session $PSGitApSession -RepositoryId $PSGitApRepoId
            forEach($pr in $PRs) {
                $newPRs += New-Object -TypeName PSObject -Property @{
                    "Id" = $pr.pullRequestId
                    "Title" = $pr.title
                    "Status" = $pr.status
                }
            }
        }
        GitHub {
			$PRs = Get-GitHubPullRequest
            forEach($pr in $PRs) {
                $newPRs += New-Object -TypeName PSObject -Property @{
                    "Id" = $pr.PullRequestNumber
                    "Title" = $pr.title
                    "Status" = $pr.state
                }
            }
        }
        default {
            Write-Error "Platform $Platform is not supported"
            exit 1
        }
    }
    $defaultDisplaySet = 'Id','Title', "Status"
	$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
	$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    $newPRs | Add-Member MemberSet PSStandardMembers $PSStandardMembers

    return $newPRs
}

Function New-PSGitPullRequest {
    <#
    .SYNOPSIS
        Create Pull Request on draft mode

    .PARAMETER Title
        Title

    .PARAMETER Description
        Description

    .EXAMPLE
		# Create pull request from current working branch to master branch
        New-PSGitPullRequest -Name "test" -Description "Test PR"

    .EXAMPLE
		# Create pull request from test branch to main branch
        New-PSGitPullRequest -SourceBranch "test" -TargetBranch "main" -Name "test" -Description "Test PR"
    #>
    param (
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$SourceBranch = $(git branch --show-current),
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$TargetBranch = "master",
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Title,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Description
    )

    switch($PSGitPlatform) {
        AzureDevOps {
            try {
                $SourceBranchRef = "refs/heads/$SourceBranch"
                $TargetBranchRef = "refs/heads/$TargetBranch"
                $newPR = New-APGitPullRequest -Session $PSGitApSession -RepositoryId $PSGitApRepoId `
                    -SourceBranchRef $SourceBranchRef -TargetBranchRef $TargetBranchRef `
                    -Title $Title -Description $Description -IsDraft
            } catch {
				Write-Host "##[error] Exception.Message: $($_.Exception.Message)" -ForegroundColor Red
				Write-Host "##[error] Server response: $($_)" -ForegroundColor Red
				throw "New-PSGitPullRequest failed"
            }
        }
        GitHub {
            try {
                $newPR = New-GitHubPullRequest `
                    -Head $SourceBranch -Base $TargetBranch `
                    -Title $Title -Body $Description `
                    -Draft
            } catch {
				Write-Host "##[error] Exception.Message: $($_.Exception.Message)" -ForegroundColor Red
				Write-Host "##[error] Server response: $($_)" -ForegroundColor Red
				throw "New-PSGitPullRequest failed"
            }
        }
        default {
            Write-Error "Platform $Platform is not supported"
            exit 1
        }
    }
    return $newPR
}
