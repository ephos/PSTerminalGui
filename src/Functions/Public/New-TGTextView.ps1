function New-TGTextView {
    <#
    .SYNOPSIS
    Creates a multi-line text editor.

    .PARAMETER Text
    Initial text.

    .PARAMETER ReadOnly
    Prevent editing.

    .PARAMETER WordWrap
    Wrap long lines.

    .PARAMETER OnTextChanged
    Scriptblock run after the contents change. $this.Text is the new text.

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
    Hashtable of any other TextView properties to set.

    .EXAMPLE
    TGTextView (Get-Content ./notes.txt -Raw) -Id notes -Width Fill -Height Fill -WordWrap
    #>
    [CmdletBinding()]
    [Alias('TGTextView')]
    [OutputType([Terminal.Gui.Views.TextView])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Text,

        [Parameter(Mandatory=$false)]
        [switch]
        $ReadOnly,

        [Parameter(Mandatory=$false)]
        [switch]
        $WordWrap,

        [Parameter(Mandatory=$false)]
        [scriptblock]
        $OnTextChanged,

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
        $view = [Terminal.Gui.Views.TextView]::new()
        if ($PSBoundParameters.ContainsKey('Text')) { $view.Text = $Text }
        if ($ReadOnly) { $view.ReadOnly = $true }
        if ($WordWrap) { $view.WordWrap = $true }
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($OnTextChanged) {
            Register-TGEventInternal -InputObject $view -EventName 'ContentsChanged' -Action $OnTextChanged
        }
        $view
    }
}