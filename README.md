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

Missing features from PowerShellForGitHub:
* Environments management support https://github.com/microsoft/PowerShellForGitHub/issues/342

Missing features from AzurePipelinesPS:
* Linux support https://github.com/Dejulia489/AzurePipelinesPS/pull/24
* Pull Request support https://github.com/Dejulia489/AzurePipelinesPS/pull/23

# Usage
```powershell
# Clone this repo
git clone https://github.com/olljanat/PSGit

# Install depended modules (note AzurePipelinesPS is temporarily included to this repo)
Install-Module -Name PowerShellForGitHub -Scope CurrentUser -RequiredVersion "0.16.0" -Force

# Import this module
Import-Module .\PSGit.psm1 -Force
```

## Login
### Azure DevOps
```powershell
$AzDevToken = Read-Host -AsSecureString -Prompt "Give Azure DevOps PAT"
Invoke-PSGitLogin -Platform "AzureDevOps" -Project "PSGitLab" -GitRepo "PSGitLab" -SecureToken $AzDevToken -Uri "https://dev.azure.com/olljanat"
```
### GitHub
```powershell
$GitHubToken = Read-Host -AsSecureString -Prompt "Give GitHub PAT"
Invoke-PSGitLogin -Platform "GitHub" -Project "PSGitLab" -GitRepo "PSGitLab" -SecureToken $GitHubToken -Uri "https://github.com"
```

## Using platform independent cmdlets
```powershell
# List PSGit commands:
Get-Command -Module PSGit | Where-Object {$_.Name -like "*-PSGit*"}

# Fully working example commands:
Get-PSGitRepo
Get-PSGitPullRequest
```
For more details look tests on *PSGit.Tests.ps1*
