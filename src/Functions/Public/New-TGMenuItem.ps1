function New-TGMenuItem {
    <#
    .SYNOPSIS
    Creates a menu entry for New-TGMenuBarItem or New-TGPopoverMenu.

    .PARAMETER Title
    Entry caption. Use _ before a letter to make it the hotkey.

    .PARAMETER OnAccept
    Scriptblock run when the entry is chosen.

    .PARAMETER Key
    Shortcut key, e.g. 'Ctrl+Q'.

    .PARAMETER HelpText
    Text shown beside the caption.

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
    Hashtable of any other MenuItem properties to set.

    .EXAMPLE
    TGMenuItem '_Save' { Save-Document } -Key Ctrl+S -HelpText 'Save the file'
    #>
    [CmdletBinding()]
    [Alias('TGMenuItem')]
    [OutputType([Terminal.Gui.Views.MenuItem])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Title,

        [Parameter(Mandatory=$false, Position=1)]
        [scriptblock]
        $OnAccept,

        [Parameter(Mandatory=$false)]
        [Terminal.Gui.Input.Key]
        $Key,

        [Parameter(Mandatory=$false)]
        [string]
        $HelpText,

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
        $action = if ($OnAccept) { [Action]$OnAccept } else { $null }
        $menuKey = if ($Key) { $Key } else { [Terminal.Gui.Input.Key]::Empty }
        $view = [Terminal.Gui.Views.MenuItem]::new($Title, $HelpText, $action, $menuKey)
        $null = $PSBoundParameters.Remove('Title')
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        $view
    }
}