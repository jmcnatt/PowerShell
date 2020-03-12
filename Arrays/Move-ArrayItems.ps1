<#
    .SYNOPSIS
    Reverses a set of objects in an array based on an input object, a starting position, and ending position.

    .DESCRIPTION
    This practice script explores array indexing and combing pieces of arrays.

    The input object is a array of objects. The objects between and including the starting position, $Start, 
    and the ending position, $End, are to be reversed.  The rest of the array is to remain untouched in the 
    results.

    For example:
    Input:  a, b, c, d, e
    Start: 2
    End:   4
    Results:  a, b, e, d, c

    The input respects the starting point of the array, 0.

    The script will error if Start is greater than end.
    The script will error if Start is less than 0.
    The script will error if End is greater than the total number of elements in the array.

    .INPUTS
    None. This script does not accept input from the pipeline.

    .OUTPUTS
    System.Object An array whose elements have been moved.

    .EXAMPLE
    .\Move-ArrayItems.ps1 -InputObject @('a', 'b', 'c', 'd', 'e') -Start 2 -End 4
    a
    b
    e
    d
    c

    .LINK
    Jimmy McNatt on GitHub: https://github.com/jmcnatt/PowerShell
#>
[CmdletBinding()]

param (
    # The array of elements
    [Parameter(Mandatory = $true)]
    [System.Object[]]
    $InputObject,

    # The starting position of elements to reverse
    [Parameter(Mandatory = $true)]
    [Int]
    $Start,

    # The ending position of elements to reverse
    [Parameter(Mandatory = $true)]
    [Int]
    $End
)

process {

    # Check to make sure $Start is greater than or equal to 0
    if ($Start -lt 0) {
        throw "Start($Start) should be greater than or equal to 0"
    }

    # Check to make sure $End is not greater than the total number of elements
    if ($End -gt $InputObject.Length - 1) {
        throw "End($End) should be less than the total number of elements, minus 1 ($($InputObject.Count - 1))"
    }

    # Check to make sure $Start is not greater than $End
    if ($Start -gt $End) {
        throw "Start($Start) should not be greater than End($End)"
    }

    # Begin building the output if the starting position isn't 0
    if ($Start -gt 0) {
        $OutputObject = $InputObject[0..($Start - 1)]
    }

    # Build the reversed array
    $OutputObject += $InputObject[$End..$Start]

    # If the ending position isn't the end, tack on the rest of the original array
    if ($End -lt $InputObject.Count - 1) {
        $OutputObject += $InputObject[($End + 1)..($InputObject.Count - 1)]
    }

    $OutputObject

}