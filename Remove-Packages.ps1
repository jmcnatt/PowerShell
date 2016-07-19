<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER

    .EXAMPLE

#>

[CmdletBinding()]

param
(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Input
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

    function Remove-Package
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [String] $Name
        )

        ([String] (dism /Online /Get-ProvisionedAppxPackages | Select-String "$Name")) -Match "PackageName : (?<packagename>.*)" | Out-Null

        if (-not $Matches['packagename'])
        {
            Write-Host "Could not find package '$Name'"
        }

        else
        {
            dism /Online /Remove-ProvisionedAppxPackage /PackageName:$Name
        }
    }  
}

process
{
    
}

end
{

}
