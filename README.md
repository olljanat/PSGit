# PSGit
*PSGit* provides cmdlets which can be used to create and manage GIT repositories, pull requests, work items, CI/CD pipelines, etc on platform independent way.

Following platforms are currently supported:
* Azure DevOps
* GitHub (Enteprise)

# Related issues
* https://github.com/Dejulia489/AzurePipelinesPS/issues/22
* https://github.com/microsoft/PowerShellForGitHub/issues/340

# Usage

## Azure DevOps
```powershell
Import-Module .\PSGit.psm1 -Force
$AzDevToken = Read-Host -AsSecureString -Prompt "Give Azure DevOps PAT"
Invoke-PSGitLogin -Platform "AzureDevOps" -Project "PSGitLab" -SecureToken $AzDevToken -Uri "https://dev.azure.com/olljanat"

Get-PSGitRepos
name     webUrl
----     ------
PSGitLab https://dev.azure.com/olljanat/PSGitLab/_git/PSGitLab
```

## GitHub
```powershell
Import-Module .\PSGit.psm1 -Force
$GitHubToken = Read-Host -AsSecureString -Prompt "Give GitHub PAT"
Invoke-PSGitLogin -Platform "GitHub" -Project "PSGitLab" -SecureToken $GitHubToken -Uri "https://github.com"

Get-PSGitRepos

full_name         visibility description
---------         ---------- -----------
PSGitLab/PSGitLab private    PSGitLab 
```
