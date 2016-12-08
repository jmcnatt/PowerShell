<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER

    .EXAMPLE

#>

[CmdletBinding()]

param
(

)

begin
{        
    # Ensure that the drvinst command is available
    if (!(Get-Command -Name pnputil -ErrorAction SilentlyContinue))
    {
        Write-Error "pnputil is not a valid command. Cannot install drivers."
        Exit    
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

end
{

}
