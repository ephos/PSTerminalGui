function Start-TGApplication {
    <#
    .SYNOPSIS
    Runs a window or dialog as a Terminal.Gui application.

    .DESCRIPTION
    Creates and initializes a Terminal.Gui application, runs the given view until it is closed
    (Esc, Stop-TGApplication, or a dialog button), then shuts the application down and restores the terminal.

    When an application is already running (e.g. called from an event handler), the view is run
    as a nested modal session on the existing application instead.

    Errors thrown inside event handlers stop the application and are rethrown after the terminal is restored.

    .PARAMETER View
    The Window, Dialog, or other runnable view to run.

    .PARAMETER Driver
    Terminal.Gui driver to use. Defaults to the platform default.

    .EXAMPLE
    New-TGWindow -Title 'Hello (Esc quits)' { New-TGLabel 'Hello world' -X Center -Y Center } | Start-TGApplication

    .OUTPUTS
    The run result of the view, e.g. the index of the button that closed a dialog. Nothing when there is no result.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [Terminal.Gui.App.IRunnable]
        $View,

        [Parameter(Mandatory=$false)]
        [ValidateSet('ansi', 'dotnet', 'windows')]
        [string]
        $Driver
    )

    process {
        # Nested run, e.g. a dialog opened from a button handler.
        if ($script:TGApp) {
            $result = $script:TGApp.Run($View, $null)
            if ($null -ne $result) { $result }
            return
        }

        $app = [Terminal.Gui.App.Application]::Create()
        $script:TGApp = $app
        $script:TGRunError = $null

        try {
            $driverName = if ($Driver) { $Driver } else { $null }
            $null = $app.Init($driverName)

            foreach ($timeout in $script:TGPendingTimeouts) {
                $timeout.Handle = $app.AddTimeout($timeout.Interval, $timeout.Callback)
            }

            # Drain work queued from other runspaces by Invoke-TGOnUIThread.
            $queue = [AppDomain]::CurrentDomain.GetData($script:TGUIQueueKey)
            $null = $app.AddTimeout([TimeSpan]::FromMilliseconds(50), [Func[bool]] {
                $item = $null
                while ($queue.TryDequeue([ref]$item)) {
                    $work = [scriptblock]::Create($item.ScriptBlock)
                    $workArgs = @($item.ArgumentList)
                    $null = & $work @workArgs
                }
                $true
            }.GetNewClosure())

            $errorHandler = [Func[Exception, bool]] {
                param($exception)
                if (-not $script:TGRunError) { $script:TGRunError = $exception }
                $script:TGApp.RequestStop()
                $true
            }

            $result = $app.Run($View, $errorHandler)
        } finally {
            $app.Dispose()
            $script:TGApp = $null
            $script:TGPendingTimeouts.Clear()
        }

        if ($script:TGRunError) {
            $exception = $script:TGRunError
            while ($exception.InnerException) { $exception = $exception.InnerException }
            $script:TGRunError = $null
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new($exception, 'TGApplicationError', 'NotSpecified', $View)
            )
        }

        if ($null -ne $result) { $result }
    }
}
