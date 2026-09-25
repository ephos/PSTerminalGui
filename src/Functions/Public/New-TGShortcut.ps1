function New-TGShortcut {
    <#
    .SYNOPSIS
    Creates a key shortcut, shown in a status bar.

    .DESCRIPTION
    The key works anywhere in the application unless -ViewScoped is used.

    .PARAMETER Key
    Key, e.g. 'Ctrl+Q' or 'F1'.

    .PARAMETER Title
    Caption shown beside the key.

    .PARAMETER OnAccept
    Scriptblock run when the key is pressed or the shortcut clicked.

    .PARAMETER HelpText
    Extra help text.

    .PARAMETER ViewScoped
    Only respond to the key when the shortcut's parent has focus.

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
    Hashtable of any other Shortcut properties to set.

    .EXAMPLE
    TGShortcut F1 'Help' { Show-TGMessageBox 'Press Esc to quit.' }
    #>
    [CmdletBinding()]
    [Alias('TGShortcut')]
    [OutputType([Terminal.Gui.Views.Shortcut])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [Terminal.Gui.Input.Key]
        $Key,

        [Parameter(Mandatory=$false, Position=1)]
        [string]
        $Title,

        [Parameter(Mandatory=$false, Position=2)]
        [scriptblock]
        $OnAccept,

        [Parameter(Mandatory=$false)]
        [string]
        $HelpText,

        [Parameter(Mandatory=$false)]
        [switch]
        $ViewScoped,

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
        $view = [Terminal.Gui.Views.Shortcut]::new($Key, $Title, $action, $HelpText)
        $view.BindKeyToApplication = -not $ViewScoped
        $null = $PSBoundParameters.Remove('Title')
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        $view
    }
}