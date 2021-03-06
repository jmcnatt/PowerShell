<#
    .SYNOPSIS
    Installs drivers in the current directory with pnputil

    .DESCRIPTION
    Interates the current directories and subdirectories and installs drivers with pnputil.
    Looks for .inf files and their supporting binaries.
    pnputil force installs the driver but may need additional input for confirmation.
#>

begin
{        
    # Ensure that the drvinst command is available
    if (!(Get-Command -Name pnputil -ErrorAction SilentlyContinue))
    {
        Write-Error "pnputil is not a valid command. Cannot install drivers."
        exit 1
    }       
}

process
{
    # Get all INF files in this directory and sub directories, then install them
    $Files = Get-ChildItem -Recurse -Filter "*.inf"

    foreach ($File in $Files)
    {
        pnputil -f -a $File.FullName
    }
}