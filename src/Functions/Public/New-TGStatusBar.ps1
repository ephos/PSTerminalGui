function New-TGStatusBar {
    <#
    .SYNOPSIS
    Creates a status bar along the bottom of its parent. Add entries with New-TGShortcut.

    .PARAMETER Content
    Scriptblock that outputs New-TGShortcut views.

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
    Hashtable of any other StatusBar properties to set.

    .EXAMPLE
    TGStatusBar {
        TGShortcut Ctrl+Q 'Quit' { Stop-TGApplication }
    }
    #>
    [CmdletBinding()]
    [Alias('TGStatusBar')]
    [OutputType([Terminal.Gui.Views.StatusBar])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [scriptblock]
        $Content,

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
        $items = [System.Collections.Generic.List[Terminal.Gui.Views.Shortcut]]::new()
        if ($Content) {
            foreach ($item in (& $Content)) {
                if ($item -is [Terminal.Gui.Views.Shortcut]) { $items.Add($item) }
            }
        }
        $view = [Terminal.Gui.Views.StatusBar]::new($items)
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        $view
    }
}