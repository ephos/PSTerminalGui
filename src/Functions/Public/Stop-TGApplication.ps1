function Stop-TGApplication {
    <#
    .SYNOPSIS
    Stops the running view (or a specific one), returning control to the caller of Start-TGApplication.

    .PARAMETER View
    Runnable view to stop. Defaults to the top-most running view.

    .EXAMPLE
    New-TGButton 'Quit' -OnAccept { Stop-TGApplication }
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Terminal.Gui.App.IRunnable]
        $View
    )

    process {
        $app = Get-TGApplication
        if ($View) {
            $app.RequestStop($View)
        } else {
            $app.RequestStop()
        }
    }
}
