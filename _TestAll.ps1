param (
    [string]
)


$AzDevToken = ConvertTo-SecureString -AsPlainText $PlainTextPAT -Force
import-module .\PSGit.psm1 -Force

Write-Output "Testing Azure DevOps"
Invoke-PSGitLogin -Platform "AzureDevOps" -Project "PSGitLab" -GitRepo "PSGitLab" -SecureToken $AzDevToken -Uri "https://dev.azure.com/olljanat"
Get-PSGitRepo
$env = New-PSGitEnvironment -Name "test" -Description "test environment"
Get-PSGitEnvironment
Remove-PSGitEnvironment -EnvironmentId "$($env.id)"
Get-PSGitPullRequest

# Write-Output "`r`n--------------`r`n"

# Write-Output "Testing GitHub"
# Invoke-PSGitLogin -Platform "GitHub" -Project "PSGitLab" -GitRepo "PSGitLab" -SecureToken $GitHubToken -Uri "https://github.com"
# Get-PSGitRepo
# $env = New-PSGitEnvironment -Name "test" -Description "test environment"
# Get-PSGitEnvironment
# Remove-PSGitEnvironment -EnvironmentId "-"
# Get-PSGitPullRequest
