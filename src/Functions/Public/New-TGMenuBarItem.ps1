function New-TGMenuBarItem {
    <#
    .SYNOPSIS
    Creates a top-level menu for New-TGMenuBar. Add entries with New-TGMenuItem in the content block.

    .PARAMETER Title
    Menu caption, e.g. '_File'.

    .PARAMETER Content
    Scriptblock that outputs New-TGMenuItem views.

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
    Hashtable of any other MenuBarItem properties to set.

    .EXAMPLE
    TGMenuBarItem '_File' { TGMenuItem '_Open' { Show-TGOpenDialog } }
    #>
    [CmdletBinding()]
    [Alias('TGMenuBarItem')]
    [OutputType([Terminal.Gui.Views.MenuBarItem])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Title,

        [Parameter(Mandatory=$false, Position=1)]
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
        $items = [System.Collections.Generic.List[Terminal.Gui.ViewBase.View]]::new()
        if ($Content) {
            foreach ($item in (& $Content)) {
                if ($item -is [Terminal.Gui.ViewBase.View]) { $items.Add($item) }
            }
        }
        $view = [Terminal.Gui.Views.MenuBarItem]::new($Title, $items)
        $null = $PSBoundParameters.Remove('Title')
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        $view
    }
}