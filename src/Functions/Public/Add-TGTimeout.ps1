function Add-TGTimeout {
    <#
    .SYNOPSIS
    Runs a scriptblock on the UI thread after an interval, repeating while it returns $true.

    .DESCRIPTION
    Can be called before Start-TGApplication; the timeout is then registered when the application starts.
    Pending timeouts are cleared when the application exits.

    .PARAMETER Milliseconds
    Interval in milliseconds.

    .PARAMETER Interval
    Interval as a TimeSpan.

    .PARAMETER ScriptBlock
    Code to run. Return $true to run again after the next interval, anything else to stop.

    .EXAMPLE
    Add-TGTimeout -Milliseconds 1000 { (Get-TGView clock).Text = Get-Date -Format T; $true }

    .OUTPUTS
    PSTerminalGui.Timeout, pass it to Remove-TGTimeout to cancel.
    #>
    [CmdletBinding(DefaultParameterSetName='Milliseconds')]
    param (
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='Milliseconds')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Milliseconds,

        [Parameter(Mandatory=$true, ParameterSetName='TimeSpan')]
        [TimeSpan]
        $Interval,

        [Parameter(Mandatory=$true, Position=1)]
        [scriptblock]
        $ScriptBlock
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Milliseconds') {
            $Interval = [TimeSpan]::FromMilliseconds($Milliseconds)
        }

        $callback = [Func[bool]] {
            $result = & $ScriptBlock
            [bool]($result | Select-Object -Last 1)
        }.GetNewClosure()

        $timeout = [PSCustomObject]@{
            PSTypeName  = 'PSTerminalGui.Timeout'
            Interval    = $Interval
            ScriptBlock = $ScriptBlock
            Callback    = $callback
            Handle      = $null
        }

        if ($script:TGApp) {
            $timeout.Handle = $script:TGApp.AddTimeout($Interval, $callback)
        } else {
            $script:TGPendingTimeouts.Add($timeout)
        }

        $timeout
    }
}
