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
    [String] $Name
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

    function Remove-Package
    {
        param
        (
            [Parameter(Position = 0, Mandatory = $true)]
            [String] $PackageName
        )

        $AppPackageName = Get-AppxPackage -Name $PackageName

        if ($AppPackageName)
        {
            Write-Host "Removing $($AppPackageName.PackageFullName) - user"
            Remove-AppxPackage -Package $($AppPackageName.PackageFullName)
            Write-Host "$Name removed - user"
        }

        else
        {
            Write-Host "Could not remove package $PackageName - user"    
        }
    }

    function Remove-ProvisionedPackage
    {
        param
        (
            [Parameter(Position = 0, Mandatory = $true)]
            [String] $PackageName
        )

        $ProvisionedPackageName = Get-ProvisionedAppxPackage -Online | Where-Object {$_.DisplayName -like $PackageName}

        if ($ProvisionedPackageName.PackageName)
        {
            Write-Host "Removing $($ProvisionedPackageName.PackageName)"
            Remove-ProvisionedAppxPackage -Online -PackageName $ProvisionedPackageName.PackageName
            Write-Host "$Name removed (provisioned)."
        }

        else
        {
            Write-Host "Could not find package $PackageName"
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
    if ($Name -like "*WindowsFeedback*")
    {
        foreach ($Item in (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"))
        {
            if ($Item.Name -like "*WindowsFeedback*")
            {
                Set-Permissions -KeyPathq $Item.PSChildName
                Remove-RegKey -KeyName $Item.PSChildName
            }
        }
    }

    Remove-Package -PackageName $Name        
    Remove-ProvisionedPackage -PackageName $Name
}
