function Invoke-TGModal {
    [CmdletBinding()]
    param (
        # Code to run with an IApplication as its only argument
        [Parameter(Mandatory=$true)]
        [scriptblock]
        $ScriptBlock
    )

    # Runs a modal helper (message box, file dialog) inside the running application,
    # or inside a temporary one so the Show-TG* functions also work from plain scripts.
    process {
        if ($script:TGApp) {
            return & $ScriptBlock $script:TGApp
        }

        $app = [Terminal.Gui.App.Application]::Create()
        $script:TGApp = $app
        try {
            $null = $app.Init($null)
            & $ScriptBlock $app
        } finally {
            $app.Dispose()
            $script:TGApp = $null
        }
    }
}
