function New-TGOptionSelector {
    <#
    .SYNOPSIS
    Creates a set of mutually exclusive options (radio buttons).

    .PARAMETER Option
    Option captions.

    .PARAMETER Value
    Index of the initially selected option.

    .PARAMETER Horizontal
    Lay the options out in a row instead of a column.

    .PARAMETER OnValueChanged
    Scriptblock run after the selection changes. $_.NewValue is the selected index; $this.Labels[$_.NewValue] its caption.

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
    Hashtable of any other OptionSelector properties to set.

    .EXAMPLE
    TGOptionSelector 'Small', 'Medium', 'Large' -Id size -Value 1
    #>
    [CmdletBinding()]
    [Alias('TGOptionSelector')]
    [OutputType([Terminal.Gui.Views.OptionSelector])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string[]]
        $Option,

        [Parameter(Mandatory=$false)]
        [int]
        $Value,

        [Parameter(Mandatory=$false)]
        [switch]
        $Horizontal,

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
        $view = [Terminal.Gui.Views.OptionSelector]::new()
        $view.Labels = [string[]]$Option
        if ($PSBoundParameters.ContainsKey('Value')) { $view.Value = $Value }
        if ($Horizontal) { $view.Orientation = [Terminal.Gui.ViewBase.Orientation]::Horizontal }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnValueChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'ValueChanged' -Action $OnValueChanged
        }
        $view
    }
}