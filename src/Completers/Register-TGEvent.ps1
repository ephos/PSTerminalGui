# Completes -EventName with the events of the -InputObject view, or of View when it is not known yet.
Register-ArgumentCompleter -CommandName Register-TGEvent -ParameterName EventName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $type = [Terminal.Gui.ViewBase.View]
    foreach ($key in 'InputObject', 'View') {
        if ($fakeBoundParameters[$key] -and $fakeBoundParameters[$key] -isnot [scriptblock]) {
            $type = $fakeBoundParameters[$key].GetType()
        }
    }

    $type.GetEvents().Name | Sort-Object -Unique | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
