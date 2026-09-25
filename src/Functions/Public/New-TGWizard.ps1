function New-TGWizard {
    <#
    .SYNOPSIS
    Creates a multi-step Wizard dialog. Add steps with New-TGWizardStep in the content block.

    .PARAMETER Title
    Title shown in the border.

    .PARAMETER Content
    Scriptblock that outputs New-TGWizardStep views.

    .PARAMETER OnFinished
    Scriptblock run when Finish is pressed on the last step.

    .PARAMETER Id
    Id used to find the view with Get-TGView.

    .PARAMETER X
    Column: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Y
    Row: int, 'Center', 'N%', 'AnchorEnd', or a Pos from New-TGPos.

    .PARAMETER Width
    Width: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim.

    .PARAMETER Height
    Height: int, 'Fill', 'Fill-N', 'Auto', 'N%', or a Dim from New-TGDim.

    .PARAMETER Property
    Hashtable of any other Wizard properties to set.

    .EXAMPLE
    TGWizard 'Setup' {
        TGWizardStep 'Welcome' -HelpText 'Press Next to continue.' { TGLabel 'Welcome!' }
        TGWizardStep 'Name' { TGTextField -Id name -Width 30 }
    } -OnFinished { $script:name = (Get-TGView name).Text } | Start-TGApplication
    #>
    [CmdletBinding()]
    [Alias('TGWizard')]
    [OutputType([Terminal.Gui.Views.Wizard])]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]
        $Title,

        [Parameter(Mandatory=$false, Position=1)]
        [scriptblock]
        $Content,

        [Parameter(Mandatory=$false)]
        [scriptblock]
        $OnFinished,

        [Parameter(Mandatory=$false)]
        [string]
        $Id,

        [Parameter(Mandatory=$false)]
        [object]
        $X,

        [Parameter(Mandatory=$false)]
        [object]
        $Y,

        [Parameter(Mandatory=$false)]
        [object]
        $Width,

        [Parameter(Mandatory=$false)]
        [object]
        $Height,

        [Parameter(Mandatory=$false)]
        [hashtable]
        $Property
    )

    process {
        $view = [Terminal.Gui.Views.Wizard]::new()
        Set-TGViewCommon -View $view -BoundParameters $PSBoundParameters
        if ($Content) {
            foreach ($step in (& $Content)) {
                if ($step -is [Terminal.Gui.Views.WizardStep]) { $view.AddStep($step) }
            }
        }
        if ($OnFinished) {
            # Finish on the last step raises Accepting on the wizard itself.
            Register-TGEventInternal -InputObject $view -EventName 'Accepting' -Action $OnFinished
        }
        $view
    }
}