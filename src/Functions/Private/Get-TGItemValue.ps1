function Get-TGItemValue {
    [CmdletBinding()]
    [OutputType([single])]
    param (
        # Object to read the number from
        [Parameter(Mandatory=$false)]
        [object]
        $InputObject,

        # Property name, or scriptblock with the object in $_. Without it, the object itself is the number.
        [Parameter(Mandatory=$false)]
        [object]
        $Selector
    )

    process {
        $value = if ($Selector -is [scriptblock]) {
            $InputObject | ForEach-Object -Process $Selector | Select-Object -Last 1
        } elseif ($Selector) {
            $InputObject.$Selector
        } else {
            $InputObject
        }

        $number = $value -as [single]
        if ($null -eq $number) {
            $what = if ($Selector) { "'$Selector' of " } else { '' }
            throw "Cannot chart $what'$InputObject': '$value' is not a number."
        }
        $number
    }
}
