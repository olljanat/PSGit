param (
    [Parameter(Mandatory = $true)][ValidateSet("AzureDevOps","GitHub")][string]$Platform,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Project,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$GitRepo,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Uri,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$PlainTextPAT
)
Import-Module -Name Pester -MinimumVersion "5.3.0"

$CIFormat = $Platform
if ($Platform -eq "GitHub") {
    $CIFormat = "GithubActions"
}

$container = New-PesterContainer -Path 'PSGit.Tests.ps1' -Data @{
    Platform = $Platform
    Project = $Project
    GitRepo = $GitRepo
    Uri = $Uri
    PlainTextPAT = $PlainTextPAT
}
$configuration = [PesterConfiguration]@{
    Run = @{
        Container = @(
            $container
        )
    }
    Should = @{
        ErrorAction = "Stop"
    }
    Output = @{
        CIFormat = $CIFormat
        Verbosity = "Detailed"
    }
    Debug = @{
        ShowFullErrors = "Full"
    }
}
Invoke-Pester -Configuration $configuration
