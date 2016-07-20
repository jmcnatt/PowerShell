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
            [String] $KeyName
        )

        $Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\$KeyName\Owners"
        
        if (Test-Path $Path)
        {
            Set-Permissions -KeyPath $Path
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
    
    function Set-Permissions
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [String] $KeyPath
        )
        
        $Owner = New-Object System.Security.Principal.NTAccount("Administrators")
        $KeyObject = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($KeyPath, 'ReadWriteSubTree', 'TakeOwnership')
        $Acl = $KeyObject.GetAccessControl()
        $Acl.SetOwner($Owner)
        $KeyObject.SetAccessControl($Acl)

        $Acl = $KeyObject.GetAccessControl()
        $Rule = New-Object System.Security.AccessControl.RegistryAccessRule("Administrators", "FullControl", "ContainerInherit", "None", "Allow")
        $Acl.SetAccessRule($Rule)
        $KeyObject.SetAccessControl($Acl)
    }
}

process
{
    if (-not $AppxPackage)
    {
        Write-Host "Could not find AppxPackage."
        exit
    }
    
    # Define PackageName variable
    ([String] (dism /Online /Get-ProvisionedAppxPackages | Select-String "$Name")) -Match "PackageName : (?<packagename>.*)" | Out-Null
    
    if ($Matches)
    {
        $PackageName = $Matches['packagename']
    }

    else
    {
        Write-Host "Could not find $($AppxPackage).Name in the DISM catalog"
        exit
    }

    if ($AppxPackage.Name -like "*WindowsFeedback*")
    {
        foreach ($Item in (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"))
        {
            if ($Item.Name -like "*WindowsFeedback*")
            {
                Remove-RegKey -KeyName $Item.PSChildName
            }
        }
    }

    else
    {
        try
        {
            Remove-AppxPackage -Package $AppxPackage
            Write-Host "$($AppxPackage).Name removed (user)."
        }

        catch
        { 
            Write-Host "Could not remove $($AppxPackage).Name from this user."
        }

        try
        {
            Remove-ProvisionedPackage -Name $AppxPackage.Name
            Write-Host "$($AppxPackage).Name removed (provisioned)."
        }

        catch
        {
            Write-Host "Could not remove $($AppxPackage).Name as a provisioned package."
        }
    }
}
