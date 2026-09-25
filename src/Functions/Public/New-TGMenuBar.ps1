function New-TGMenuBar {
    <#
    .SYNOPSIS
    Creates a menu bar. Add menus with New-TGMenuBarItem in the content block.

    .PARAMETER Content
    Scriptblock that outputs New-TGMenuBarItem views.

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
    Hashtable of any other MenuBar properties to set.

    .EXAMPLE
    TGMenuBar {
        TGMenuBarItem '_File' {
            TGMenuItem '_Quit' { Stop-TGApplication } -Key Ctrl+Q
        }
    }
    #>
    [CmdletBinding()]
    [Alias('TGMenuBar')]
    [OutputType([Terminal.Gui.Views.MenuBar])]
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
        $items = [System.Collections.Generic.List[Terminal.Gui.Views.MenuItem]]::new()
        if ($Content) {
            foreach ($item in (& $Content)) {
                if ($item -is [Terminal.Gui.Views.MenuItem]) { $items.Add($item) }
            }
        }
        $view = [Terminal.Gui.Views.MenuBar]::new($items)
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        $view
    }
}