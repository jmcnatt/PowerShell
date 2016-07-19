<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER

    .EXAMPLE

#>

[CmdletBinding()]

param
(
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage] $AppxPackage
)

begin
{
    function Remove-RegKey
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [String] $Name
        )

        $Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\$Name\Owners"
        
        if (Test-Path $Path)
        {
            Remove-Item -Recurse -Force -Path $Path
            Write-Host "$Path Removed."
        }

        else
        {
            Write-Host "Could not find registry key $Path"
        }
    }

    function Remove-ProvisionedPackage
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [String] $Name
        )

        ([String] (dism /Online /Get-ProvisionedAppxPackages | Select-String "$Name")) -Match "PackageName : (?<packagename>.*)" | Out-Null
        $PackageName = $Matches['packagename']

        if (-not $PackageName)
        {
            Write-Host "Could not find provisioned package '$PackageName'"
        }

        else
        {
            Write-Host "Removing '$PackageName'"
            dism /Online /Remove-ProvisionedAppxPackage /PackageName:$PackageName
        }
    }  
}

process
{
    if ($AppxPackage.Name -like "*WindowsFeedback*")
    {
        
    }

    else
    {
        Remove-AppxPackage -Package $AppxPackage
        Remove-ProvisionedPackage -Name $AppxPackage.Name
    }
}
