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

    if (-not (Test-Path -Path $Location))
    {
        Write-Host "The path `"$Location`" is invalid"
        Exit 1
    }

    # Append the backslash if needed
    if (-not ($Location.Substring($Location.Length - 1) -eq '\'))
    {
        $Location = $Location + '\'
    }

    Write-Host "Target location is `"$Location`""

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

    Out-File -FilePath ($Location + $Name) -InputObject $Output

    if ([bool] (Test-Path -Path ($Location + $Name)))
    {
        Write-Host "`"$Location$Name`" created."
    }
}

