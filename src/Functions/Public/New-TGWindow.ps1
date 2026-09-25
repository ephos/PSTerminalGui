function New-TGWindow {
    <#
    .SYNOPSIS
    Creates a Window, the usual top-level view passed to Start-TGApplication.

    .PARAMETER Title
    Text shown in the window border.

    .PARAMETER Content
    Scriptblock whose view output is added to the window.

    .PARAMETER Id
    Id used to find the view with Get-TGView.

    .PARAMETER X
    Column: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Y
    Row: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Width
    Width: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim. Defaults to filling the screen.

    .PARAMETER Height
    Height: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim. Defaults to filling the screen.

    .PARAMETER Property
    Hashtable of any other Window properties to set.

    .EXAMPLE
    TGWindow 'My App (Esc quits)' {
        TGLabel 'Hello' -X Center -Y Center
    } | Start-TGApplication
    #>
    [CmdletBinding()]
    [Alias('TGWindow')]
    [OutputType([Terminal.Gui.Views.Window])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
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
        $view = [Terminal.Gui.Views.Window]::new()
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($Content) { Add-TGContent -Parent $view -Content $Content }
        $view
    }
}
