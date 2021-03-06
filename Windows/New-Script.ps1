﻿<#
    .SYNOPSIS
    Generates a new powershell script.

    .DESCRIPTION
    This script can be used to create new scripts via a template. The template is built into the script
    and can be editted as needed.

    .PARAMETER Name
    The file name of the script to be created.

    .PARAMETER location
    The file system location where the script should be created.

    .EXAMPLE
    New-Script.ps1 -Name 'Do-Something'

    .EXAMPLE
    New-Script.ps1 -Name 'Do-Something' -Location 'C:\foo'

#>

[CmdletBinding()]

param
(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $Name,

    [Parameter(Position = 1, Mandatory = $false)]
    [String] $Location
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

    Write-Host "File name will be `"$Name`""

    # Check to see if the provided location is valid
    if ($Location -and (-not (Test-Path -Path $Location)))
    {
        Write-Host "The path `"$Location`" is invalid"
        Exit 1
    }

    # Append the backslash if needed
    if (-not ($Location.Substring($Location.Length - 1) -eq '\'))
    {
        $Location += '\'
    }

    Write-Host "Target location is `"$Location`""

    # Check to see if the file exists
    if ([bool] (Test-Path -Path ($Location + $Name)))
    {
        Write-Warning "The file `"$Name`" exists."
        $Choice = Read-Host -Prompt "Overwrite?"

        if ($Choice -notlike "y*") 
        { 
            Exit 1
        }
    }

    Write-Host "Creating new script file `"$Location$Name `""

    # Create the file
    Out-File -FilePath ($Location + $Name) -InputObject $Output

    # Test to see if the file creation was successful
    if ([bool] (Test-Path -Path ($Location + $Name)))
    {
        Write-Host "`"$Location$Name`" created."
    }
}

