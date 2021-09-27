param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$PlainTextPAT
)


$AzDevToken = ConvertTo-SecureString -AsPlainText $PlainTextPAT -Force
import-module .\PSGit.psm1 -Force

Write-Output "Testing Azure DevOps"
Invoke-PSGitLogin -Platform "AzureDevOps" -Project "PSGitLab" -GitRepo "PSGitLab" -SecureToken $AzDevToken -Uri "https://dev.azure.com/olljanat"
$env = New-PSGitEnvironment -Name "test" -Description "test environment"
Get-PSGitEnvironment
Remove-PSGitEnvironment -EnvironmentId "$($env.id)"
Get-PSGitPullRequest
