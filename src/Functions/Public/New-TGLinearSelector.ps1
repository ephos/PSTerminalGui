function New-TGLinearSelector {
    <#
    .SYNOPSIS
    Creates a slider that picks one of a list of options.

    .PARAMETER Option
    Option captions, shown as the legend.

    .PARAMETER Value
    Initially selected option.

    .PARAMETER Vertical
    Lay the slider out vertically.

    .PARAMETER OnValueChanged
    Scriptblock run after the selection changes. $_.NewValue is the selected option.

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
    Hashtable of any other LinearSelector properties to set.

    .EXAMPLE
    TGLinearSelector 'Low', 'Medium', 'High' -Id level -Value Medium -Width Fill
    #>
    [CmdletBinding()]
    [Alias('TGLinearSelector')]
    [OutputType([Terminal.Gui.Views.LinearSelector])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string[]]
        $Option,

        [Parameter(Mandatory=$false)]
        [string]
        $Value,

        [Parameter(Mandatory=$false)]
        [switch]
        $Vertical,

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
        $orientation = if ($Vertical) { [Terminal.Gui.ViewBase.Orientation]::Vertical } else { [Terminal.Gui.ViewBase.Orientation]::Horizontal }
        $view = [Terminal.Gui.Views.LinearSelector]::new([System.Collections.Generic.List[string]]$Option, $orientation)
        if ($PSBoundParameters.ContainsKey('Value')) { $view.Value = $Value }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnValueChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'ValueChanged' -Action $OnValueChanged
        }
        $view
    }
}