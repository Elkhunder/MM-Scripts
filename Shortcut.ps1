$creds     = Get-Credential
#$computer  = Read-Host 'Input computer name'
$Inputfile = get-content 'C:\ScriptFiles\Computers.txt'
foreach($computer in $Inputfile){
Invoke-Command -ComputerName $computer -ScriptBlock {
$TargetFile   = 'C:\Program Files (x86)\MModal\ScribingServices\ScribingServices.exe'
#$filename = Read-Host 'Input the filename with no extensions'
$ShortcutFile = 'C:\Users\Public\Desktop\ScribingServices.lnk'
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut     = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
}}