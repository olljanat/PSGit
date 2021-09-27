# PSGit
*PSGit* provides cmdlets which can be used to create and manage GIT repositories, pull requests, work items, environments, etc on platform independent way.

It prefer compatibility instead of features which why only those features which are supported by all platforms can be added to here. Target is also have full *integration test* coverage for all features provided by PSGit.

Following platforms are currently supported:
* Azure DevOps (provided by [AzurePipelinesPS](https://www.powershellgallery.com/packages/AzurePipelinesPS))
* GitHub (Enteprise) (provided by [PowerShellForGitHub](https://www.powershellgallery.com/packages/PowerShellForGitHub))

# Related issues
General items about idea of having tool like *PSGit*
* https://github.com/Dejulia489/AzurePipelinesPS/issues/22
* https://github.com/microsoft/PowerShellForGitHub/issues/340

Missing features from GitHub side:
* Environments management support https://github.com/microsoft/PowerShellForGitHub/issues/342

# Usage
## Azure DevOps
```powershell
Import-Module .\PSGit.psm1 -Force
$AzDevToken = Read-Host -AsSecureString -Prompt "Give Azure DevOps PAT"
Invoke-PSGitLogin -Platform "AzureDevOps" -Project "PSGitLab" -SecureToken $AzDevToken -Uri "https://dev.azure.com/olljanat"

Get-PSGitRepos
Id         : 7536e5fe-dc07-43ad-8230-44c22af3963b
Name       : a
Url        : https://dev.azure.com/olljanat/PSGit/_git/a
Visibility : public
IsDisable  : False

Id         : 78781818-5440-42be-9771-6e04986b1324
Name       : PSGit
Url        : https://dev.azure.com/olljanat/PSGit/_git/PSGit
Visibility : public
IsDisable  : False
```

## GitHub
```powershell
Import-Module .\PSGit.psm1 -Force
$GitHubToken = Read-Host -AsSecureString -Prompt "Give GitHub PAT"
Invoke-PSGitLogin -Platform "GitHub" -Project "PSGitLab" -SecureToken $GitHubToken -Uri "https://github.com"

Get-PSGitRepos
Id         : 409959616
Name       : PSGitLab
Url        : https://github.com/PSGitLab/PSGitLab
Visibility : private
IsDisable  : False

Id         : 410751460
Name       : environments-lab
Url        : https://github.com/PSGitLab/environments-lab
Visibility : public
IsDisable  : False
```
