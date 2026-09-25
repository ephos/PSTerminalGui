function Add-TGView {
    <#
    .SYNOPSIS
    Adds one or more child views to a parent view.

    .PARAMETER Parent
    The container, e.g. a Window, Dialog, or FrameView.

    .PARAMETER View
    Views to add. Accepts pipeline input.

    .PARAMETER PassThru
    Output the parent after adding.

    .EXAMPLE
    $win = New-TGWindow -Title 'Demo'
    New-TGLabel 'Hi' | Add-TGView -Parent $win
    #>
    [CmdletBinding()]
    [OutputType([Terminal.Gui.ViewBase.View])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [Terminal.Gui.ViewBase.View]
        $Parent,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [Terminal.Gui.ViewBase.View[]]
        $View,

        [Parameter(Mandatory=$false)]
        [switch]
        $PassThru
    )

    process {
        foreach ($child in $View) {
            $null = $Parent.Add($child)
        }
    }

    end {
        if ($PassThru) { $Parent }
    }
}
