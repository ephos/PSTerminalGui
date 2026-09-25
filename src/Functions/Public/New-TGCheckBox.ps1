function New-TGCheckBox {
    <#
    .SYNOPSIS
    Creates a CheckBox.

    .PARAMETER Text
    Caption. Use _ before a letter to make it the hotkey.

    .PARAMETER Checked
    Start checked. Read the state later with $view.Value -eq 'Checked'.

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
    Hashtable of any other CheckBox properties to set.

    .EXAMPLE
    TGCheckBox '_Verbose' -Id verbose -Checked -OnValueChanged { $script:verbose = $_.NewValue -eq 'Checked' }
    #>
    [CmdletBinding()]
    [Alias('TGCheckBox')]
    [OutputType([Terminal.Gui.Views.CheckBox])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Text,

        [Parameter(Mandatory=$false)]
        [switch]
        $Checked,

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
        $view = [Terminal.Gui.Views.CheckBox]::new()
        if ($PSBoundParameters.ContainsKey('Text')) { $view.Text = $Text }
        if ($Checked) { $view.Value = [Terminal.Gui.Views.CheckState]::Checked }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnValueChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'ValueChanged' -Action $OnValueChanged
        }
        $view
    }
}