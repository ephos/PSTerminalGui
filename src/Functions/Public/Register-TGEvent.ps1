function Register-TGEvent {
    <#
    .SYNOPSIS
    Attaches a scriptblock handler to any event of a Terminal.Gui object.

    .DESCRIPTION
    Inside the handler, $this is the sender and $_ is the event args. The same values are
    also passed as positional arguments, so param($sender, $e) works too.

    .PARAMETER InputObject
    The view (or other Terminal.Gui object) raising the event.

    .PARAMETER EventName
    Name of the .NET event, e.g. 'Accepting', 'ValueChanged', 'KeyDown'.

    .PARAMETER Action
    Scriptblock to run when the event is raised.

    .PARAMETER SetHandled
    Set $_.Handled = $true after the action runs, so the event does not propagate further.

    .PARAMETER PassThru
    Output the input object, so calls can be chained in a content block.

    .EXAMPLE
    New-TGTextField -Id name | Register-TGEvent -EventName KeyDown -Action { Write-Debug $_.KeyCode } -PassThru
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Alias('View')]
        [object]
        $InputObject,

        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $EventName,

        [Parameter(Mandatory=$true, Position=1)]
        [scriptblock]
        $Action,

        [Parameter(Mandatory=$false)]
        [switch]
        $SetHandled,

        [Parameter(Mandatory=$false)]
        [switch]
        $PassThru
    )

    process {
        Register-TGEventInternal -InputObject $InputObject -EventName $EventName -Action $Action -SetHandled:$SetHandled
        if ($PassThru) { $InputObject }
    }
}
