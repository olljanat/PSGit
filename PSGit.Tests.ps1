param (
    [Parameter(Mandatory = $true)][ValidateSet("AzureDevOps","GitHub")][string]$Platform,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Project,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$GitRepo,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Uri,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$PlainTextPAT
)

$SecureToken = ConvertTo-SecureString -AsPlainText $PlainTextPAT -Force
Import-Module .\PSGit.psm1 -Force
Invoke-PSGitLogin -Platform $Platform -Project $Project -GitRepo $GitRepo -Uri $Uri -SecureToken $SecureToken

Describe 'PSGitEnvironment' {
    It "Executing New-PSGitEnvironment" {
        { New-PSGitEnvironment -Name "xTestAutomation - PSGit" -Description "Created by New-PSGitEnvironment CI test" } | Should -Not -Throw
        Start-Sleep -Seconds 1
    }

    It "Executing Get-PSGitEnvironment" {
        $env = Get-PSGitEnvironment | Where-Object {$_.name -eq "xTestAutomation - PSGit"}
        $env.id | Should -Not -BeNullOrEmpty
        { [int]$env.id } | Should -Not -Throw
        $global:envID = $env.id
        Start-Sleep -Seconds 1
    }

    It "Executing Remove-PSGitEnvironment" {
        { Remove-PSGitEnvironment -Id $envID } | Should -Not -Throw
        Start-Sleep -Seconds 1
    }
}
