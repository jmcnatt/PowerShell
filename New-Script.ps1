<#
    .SYNOPSIS
    Generates a new powershell script

    .DESCRIPTION
    This script can be used to create new scripts via a template. The template is built into the script
    and can be editted as needed.

#>

[CmdletBinding()]

param
(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Name
)

begin
{
   $Output = @"
<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER

    .EXAMPLE

#>

[CmdletBinding()]

param
(
    [Parameter(Position = 0, Mandatory = `$true)]
    [ValidateNotNullOrEmpty()]
    [String] `$Input
)

begin
{

}

process
{

}

end
{

}
"@ 
}

process
{    
    if ($Name -notlike "*.ps1")
    {
        Write-Host "Appending .ps1 to file name"
        $Name += '.ps1'
    }

    if ([bool] (Test-Path -Path $Name))
    {
        Write-Warning "The file `"$Name`" exists."
        $Choice = Read-host -Prompt "Overwrite?"

        if ($Choice -notlike "y*") { Exit }
    }

    Out-File -FilePath $Name -InputObject $Output

    if ([bool] (Test-Path -Path $Name))
    {
        Write-Host "$Name created."
        psedit $Name
    }
}

