param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$PlainTextPAT
)


$GitHubToken = ConvertTo-SecureString -AsPlainText $PlainTextPAT -Force
import-module .\PSGit.psm1 -Force

Write-Output "Testing GitHub"
Invoke-PSGitLogin -Platform "GitHub" -Project "PSGitLab" -GitRepo "PSGitLab" -SecureToken $GitHubToken -Uri "https://github.com"
$env = New-PSGitEnvironment -Name "test" -Description "test environment"
Get-PSGitEnvironment
Remove-PSGitEnvironment -EnvironmentId "-"
Get-PSGitPullRequest
