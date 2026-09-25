function Remove-TGTimeout {
    <#
    .SYNOPSIS
    Cancels a timeout created by Add-TGTimeout.

    .PARAMETER Timeout
    Object returned by Add-TGTimeout.

    .EXAMPLE
    $t = Add-TGTimeout 500 { $true }
    Remove-TGTimeout -Timeout $t
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [PSTypeName('PSTerminalGui.Timeout')]
        [PSCustomObject]
        $Timeout
    )

    process {
        $null = $script:TGPendingTimeouts.Remove($Timeout)
        if ($Timeout.Handle -and $script:TGApp) {
            $null = $script:TGApp.RemoveTimeout($Timeout.Handle)
        }
        $Timeout.Handle = $null
    }
}
