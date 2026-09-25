function Show-TGPopoverMenu {
    <#
    .SYNOPSIS
    Shows a menu created with New-TGPopoverMenu, e.g. as a right-click context menu.

    .PARAMETER Menu
    The menu to show.

    .PARAMETER X
    Screen column. Defaults to the last mouse position.

    .PARAMETER Y
    Screen row. Defaults to the last mouse position.

    .EXAMPLE
    $menu = TGPopoverMenu { TGMenuItem 'Refresh' { Update-List } }
    TGShortcut F2 'Menu' { Show-TGPopoverMenu $menu -X 2 -Y 2 }
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Terminal.Gui.Views.PopoverMenu]
        $Menu,

        [Parameter(Mandatory=$false)]
        [int]
        $X,

        [Parameter(Mandatory=$false)]
        [int]
        $Y
    )

    process {
        $app = Get-TGApplication
        if (-not $app.Popovers.IsRegistered($Menu)) {
            $null = $app.Popovers.Register($Menu)
        }

        $point = if ($PSBoundParameters.ContainsKey('X') -or $PSBoundParameters.ContainsKey('Y')) {
            [System.Drawing.Point]::new($X, $Y)
        } else {
            $app.Mouse.LastMousePosition
        }

        $Menu.MakeVisible($point, $null)
    }
}
