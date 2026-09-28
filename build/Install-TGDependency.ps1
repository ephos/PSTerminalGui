# Restores Terminal.Gui for development. Importing the module restores it when missing; pass -Force to restore again.
# Users of the published module run Install-TGDependency directly.
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../src/PSTerminalGui.psd1') -Force
Install-TGDependency @args
