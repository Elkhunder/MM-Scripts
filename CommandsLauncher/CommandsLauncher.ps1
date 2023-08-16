$ScriptPath = $MyInvocation.MyCommand.Path
Set-Location -Path (Split-Path $ScriptPath)
$FunctionPath = "../CustomFunctions/CustomFunctions.ps1"
Import-Module $FunctionPath
New-ElevatedPrompt -ScriptPath $ScriptPath
Update-Dependencies -PackageProviders "NuGet","PowerShellGet" -Verbose
$Commands = Get-ChildItem -Recurse "..\" -Include *.ps1 -Exclude testing.*, CommandsLauncher.* |
  Where-Object { ! $_.PSIsContainer } |
    Select-Object @{Name = "CommandName"; Expression = {$_.BaseName}}, @{Name = "Path"; Expression = {$_.FullName}}
$CommandNames = @()
foreach ($Command in $Commands){
  $CommandNames += $Command.name
}
$Command = New-ListBox -TitleText "Commands List" -LabelText "Select the command you wish to run" -ListBoxItems $Commands.CommandName

$CommandPath = ($Commands | Where-Object {$_.CommandName -eq $Command}).Path
Set-Location -Path (Split-Path $CommandPath)
&$CommandPath
# New-ElevatedPrompt -ScriptPath $CommandPath