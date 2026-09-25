function New-TGColorPicker {
    <#
    .SYNOPSIS
    Creates a color picker.

    .PARAMETER Value
    Initial color, e.g. 'Red' or '#FF8800'.

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
    Hashtable of any other ColorPicker properties to set.

    .EXAMPLE
    TGColorPicker '#FF8800' -Id accent -Width Fill
    #>
    [CmdletBinding()]
    [Alias('TGColorPicker')]
    [OutputType([Terminal.Gui.Views.ColorPicker])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [Terminal.Gui.Drawing.Color]
        $Value,

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
        $view = [Terminal.Gui.Views.ColorPicker]::new()
        if ($PSBoundParameters.ContainsKey('Value')) { $view.SelectedColor = $Value }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnValueChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'ValueChanged' -Action $OnValueChanged
        }
        $view
    }
}