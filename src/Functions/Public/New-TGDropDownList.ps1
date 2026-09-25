function New-TGDropDownList {
    <#
    .SYNOPSIS
    Creates a text field with a drop-down list of choices.

    .PARAMETER Item
    Choices shown in the list.

    .PARAMETER Text
    Initial text.

    .PARAMETER OnValueChanged
    Scriptblock run after the text changes. $_.NewValue is the new text.

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
    Hashtable of any other DropDownList properties to set.

    .EXAMPLE
    TGDropDownList 'Debug', 'Info', 'Warning', 'Error' -Id level -Text Info -Width 20
    #>
    [CmdletBinding()]
    [Alias('TGDropDownList')]
    [OutputType([Terminal.Gui.Views.DropDownList])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string[]]
        $Item,

        [Parameter(Mandatory=$false)]
        [string]
        $Text,

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
        $view = [Terminal.Gui.Views.DropDownList]::new()
        $view.Source = [Terminal.Gui.Views.ListWrapper[string]]::new([System.Collections.ObjectModel.ObservableCollection[string]]::new([string[]]$Item))
        if ($PSBoundParameters.ContainsKey('Text')) { $view.Text = $Text }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnValueChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'ValueChanged' -Action $OnValueChanged
        }
        $view
    }
}