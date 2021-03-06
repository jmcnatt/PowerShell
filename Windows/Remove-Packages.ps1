<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER

    .EXAMPLE

#>

[CmdletBinding()]

param
(
    [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String] $Name,

    [Parameter(Position = 1, Mandatory = $false)]
    [Switch] $CommonApps = $false
)

begin
{
    $CommonAppsList = @(
        'Microsoft.Getstarted',
        'Microsoft.WindowsFeedbackHub',
        'Microsoft.WindowsStore',
        'Microsoft.XboxApp',
        'Microsoft.WindowsAlarms',
        'king.com.CandyCrushSodaSaga',
        '9E2F88E3.Twitter',
        'Microsoft.WindowsPhone',
        'Microsoft.People',
        'Microsoft.Office.Sway',
        'Microsoft.MicrosoftSolitaireCollection',
        'Microsoft.MicrosoftOfficeHub',
        'Microsoft.Messaging',
        'Microsoft.3DBuilder',
        'Microsoft.XboxIdentityProvider',
        'Microsoft.StorePurchaseApp',
        'Microsoft.OneConnect',
        'Microsoft.SkypeApp',
        'Microsoft.Office.OneNote',
        'Microsoft.BingNews',
        'Microsoft.BingSports',
        'Microsoft.BingWeather',
        'Microsoft.BingFinance',
        'microsoft.windowscommunicationsapps',
        'Microsoft.ConnectivityStore',
        'Microsoft.CommsPhone',
        'Microsoft.LockApp',
        'Microsoft.ConnectivityStore'
    )

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

    if ($CommonApps)
    {
        foreach ($AppName in $CommonAppsList)
        {
            Write-Host "`nRemoving common Windows Apps...`n"
            Remove-Package -PackageName $AppName
            Remove-ProvisionedPackage -PackageName $AppName
            Write-Host "`nComplete.`n"
        }

        Exit 0
    }

    Remove-Package -PackageName $Name        
    Remove-ProvisionedPackage -PackageName $Name
}
