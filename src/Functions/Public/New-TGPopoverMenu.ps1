function New-TGPopoverMenu {
    <#
    .SYNOPSIS
    Creates a pop-up (context) menu. Show it with Show-TGPopoverMenu.

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
    Hashtable of any other PopoverMenu properties to set.

    .EXAMPLE
    $menu = TGPopoverMenu { TGMenuItem 'Copy' { Set-Clipboard (Get-TGView notes).SelectedText } }
    TGTextView -Id notes | Register-TGEvent MouseEvent { if ($_.Flags -band 'RightButtonClicked') { Show-TGPopoverMenu $menu } } -PassThru
    #>
    [CmdletBinding()]
    [Alias('TGPopoverMenu')]
    [OutputType([Terminal.Gui.Views.PopoverMenu])]
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
        $view = [Terminal.Gui.Views.PopoverMenu]::new($items)
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        $view
    }
}