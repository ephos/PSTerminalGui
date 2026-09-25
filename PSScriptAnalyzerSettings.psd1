@{
    ExcludeRules = @(
        # New-TG* functions only build in-memory view objects, and Set/Stop/Remove act on the running UI, not the system.
        'PSUseShouldProcessForStateChangingFunctions',
        # Parameters used inside closures (event handlers, modal scriptblocks) are reported as unused.
        'PSReviewUnusedParameter',
        # Pos and Tabs mirror Terminal.Gui type names.
        'PSUseSingularNouns'
    )
}
