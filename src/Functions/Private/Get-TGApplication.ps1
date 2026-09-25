function Get-TGApplication {
    [CmdletBinding()]
    [OutputType([Terminal.Gui.App.IApplication])]
    param ()

    process {
        if (-not $script:TGApp) {
            throw 'No Terminal.Gui application is running. Call this from inside a view started with Start-TGApplication (e.g. in an event handler).'
        }
        $script:TGApp
    }
}
