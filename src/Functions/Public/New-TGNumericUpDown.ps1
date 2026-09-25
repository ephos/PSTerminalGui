function New-TGNumericUpDown {
    <#
    .SYNOPSIS
    Creates an integer spinner with up/down buttons.

    .PARAMETER Value
    Initial value.

    .PARAMETER Increment
    Amount added or removed per step. Defaults to 1.

    .PARAMETER Format
    Composite format for the value, e.g. '{0} sec'.

    .PARAMETER OnValueChanged
    Scriptblock run after the value changes. $this is the view, $_.NewValue the new value.

    .PARAMETER Id
    Id used to find the view with Get-TGView.

    .PARAMETER X
    Column: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Y
    Row: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Width
    Width: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim.

    .PARAMETER Height
    Height: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim.

    .PARAMETER Property
    Hashtable of any other NumericUpDown properties to set.

    .EXAMPLE
    TGNumericUpDown 30 -Id timeout -Increment 5
    #>
    [CmdletBinding()]
    [Alias('TGNumericUpDown')]
    [OutputType([Terminal.Gui.Views.NumericUpDown])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [int]
        $Value,

        [Parameter(Mandatory=$false)]
        [int]
        $Increment,

        [Parameter(Mandatory=$false)]
        [string]
        $Format,

        [Parameter(Mandatory=$false)]
        [scriptblock]
        $OnValueChanged,

        [Parameter(Mandatory=$false)]
        [string]
        $Id,

        [Parameter(Mandatory=$false)]
        [object]
        $X,

        [Parameter(Mandatory=$false)]
        [object]
        $Y,

        [Parameter(Mandatory=$false)]
        [object]
        $Width,

        [Parameter(Mandatory=$false)]
        [object]
        $Height,

        [Parameter(Mandatory=$false)]
        [hashtable]
        $Property
    )

    process {
        $view = [Terminal.Gui.Views.NumericUpDown]::new()
        if ($PSBoundParameters.ContainsKey('Value')) { $view.Value = $Value }
        if ($PSBoundParameters.ContainsKey('Increment')) { $view.Increment = $Increment }
        if ($PSBoundParameters.ContainsKey('Format')) { $view.Format = $Format }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnValueChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'ValueChanged' -Action $OnValueChanged
        }
        $view
    }
}