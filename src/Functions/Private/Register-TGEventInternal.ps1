function Register-TGEventInternal {
    [CmdletBinding()]
    param (
        # Object that raises the event
        [Parameter(Mandatory=$true)]
        [object]
        $InputObject,

        # Event name, e.g. 'Accepting'
        [Parameter(Mandatory=$true)]
        [string]
        $EventName,

        # Handler. Inside it, $this is the sender and $_ is the event args.
        [Parameter(Mandatory=$true)]
        [scriptblock]
        $Action,

        # Set $_.Handled = $true after the action runs, so the event does not bubble further.
        [Parameter(Mandatory=$false)]
        [switch]
        $SetHandled
    )

    process {
        $eventInfo = $InputObject.GetType().GetEvent($EventName)
        if (-not $eventInfo) {
            throw "$($InputObject.GetType().Name) has no event named '$EventName'."
        }

        $setHandled = $SetHandled.IsPresent
        $handler = {
            param($eventSender, $eventArguments)
            $variables = [System.Collections.Generic.List[psvariable]]::new()
            $variables.Add([psvariable]::new('_', $eventArguments))
            $variables.Add([psvariable]::new('this', $eventSender))
            $null = $Action.InvokeWithContext($null, $variables, @($eventSender, $eventArguments))
            if ($setHandled -and $eventArguments.PSObject.Properties['Handled']) {
                $eventArguments.Handled = $true
            }
        }.GetNewClosure()

        $eventInfo.AddEventHandler($InputObject, ($handler -as $eventInfo.EventHandlerType))
    }
}
