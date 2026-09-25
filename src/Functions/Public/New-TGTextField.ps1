function New-TGTextField {
    <#
    .SYNOPSIS
    Creates a single-line text input.

    .PARAMETER Text
    Initial text.

    .PARAMETER Secret
    Mask input, for passwords.

    .PARAMETER ReadOnly
    Prevent editing.

    .PARAMETER OnTextChanged
    Scriptblock run after the text changes. $this is the text field, $this.Text the new text.

    .PARAMETER OnAccept
    Scriptblock run when Enter is pressed in the field.

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
    Hashtable of any other TextField properties to set.

    .EXAMPLE
    New-TGTextField -Id password -Secret -X 10 -Y 2 -Width 20
    #>
    [CmdletBinding()]
    [Alias('TGTextField')]
    [OutputType([Terminal.Gui.Views.TextField])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Text,

        [Parameter(Mandatory=$false)]
        [switch]
        $Secret,

        [Parameter(Mandatory=$false)]
        [switch]
        $ReadOnly,

        [Parameter(Mandatory=$false)]
        [scriptblock]
        $OnTextChanged,

        [Parameter(Mandatory=$false)]
        [scriptblock]
        $OnAccept,

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
        $view = [Terminal.Gui.Views.TextField]::new()
        if ($PSBoundParameters.ContainsKey('Text')) { $view.Text = $Text }
        if ($Secret) { $view.Secret = $true }
        if ($ReadOnly) { $view.ReadOnly = $true }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnTextChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'TextChanged' -Action $OnTextChanged
        }
        if ($OnAccept) {
            Register-TGEventInternal -InputObject $view -EventName 'Accepting' -Action $OnAccept -SetHandled
        }
        $view
    }
}
