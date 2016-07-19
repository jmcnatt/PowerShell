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
    # Define PackageName variable
    ([String] (dism /Online /Get-ProvisionedAppxPackages | Select-String "$Name")) -Match "PackageName : (?<packagename>.*)" | Out-Null
    $PackageName = $Matches['packagename']

    function Remove-RegKey
    {
        $Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\$PackageName\Owners"
        
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
        if (-not $PackageName)
        {
            Write-Host "Could not find provisioned package."
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
        Get-ChildItem
    }

    else
    {
        Remove-AppxPackage -Package $AppxPackage
        Remove-ProvisionedPackage -Name $AppxPackage.Name
    }
}
