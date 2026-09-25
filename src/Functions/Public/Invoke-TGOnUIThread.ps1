function Invoke-TGOnUIThread {
    <#
    .SYNOPSIS
    Queues a scriptblock to run on the UI thread of the running application.

    .DESCRIPTION
    Terminal.Gui views may only be touched from the UI thread. Use this from background work
    (Start-ThreadJob, runspaces) to update views safely. The scriptblock is re-created on the UI thread,
    so it cannot see variables from the calling runspace: pass values with -ArgumentList.

    The queue is drained every 50 ms while an application is running.

    .PARAMETER ScriptBlock
    Code to run on the UI thread. Receives -ArgumentList as positional arguments.

    .PARAMETER ArgumentList
    Values passed to the scriptblock.

    .EXAMPLE
    Start-ThreadJob {
        Import-Module PSTerminalGui
        1..100 | ForEach-Object {
            Start-Sleep -Milliseconds 50
            Invoke-TGOnUIThread { param($p) (Get-TGView progress).Fraction = $p / 100 } -ArgumentList $_
        }
    }
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory=$false)]
        [object[]]
        $ArgumentList = @()
    )

    process {
        $queue = [AppDomain]::CurrentDomain.GetData('PSTerminalGui.UIQueue')
        $queue.Enqueue([PSCustomObject]@{
            ScriptBlock  = $ScriptBlock.ToString()
            ArgumentList = $ArgumentList
        })
    }
}
