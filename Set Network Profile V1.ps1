### Create PSSession to user inputed TermID and assign it to the variable PSSession

$TermID = Read-Host -Prompt 'Input TermID'
Write-Host Opening PSSession to $TermID...
$PSSession = New-PSSession $TermID 

### Pause to allow PSSession to connect prior to continuing

Start-Sleep -Seconds 3

### Pull a list of Network Connection Profiles
Write-Host Pulling a List of Connections...
Invoke-Command -Session $PSSession -ScriptBlock {Get-NetConnectionProfile}

### Prompt for Interface Index

$InterfaceIndex = Read-Host -Prompt 'Input Interface Index'

### Change Network Category to Private for specified Interface Index

### Uncomment below area if you need to run with elevation, including the close parenthesis below the invoke command
### Start-Process powershell.exe -Verb runas -ArgumentList (

Invoke-Command -Session $PSSession -ScriptBlock {Set-NetConnectionProfile -InterfaceIndex $using:InterfaceIndex -NetworkCategory Private}

### )

###Re-Pull Connection Info to Verify Changes
Write-Host Pulling Connection Info...
Invoke-Command -Session $PSSession -ScriptBlock {Get-NetConnectionProfile -InterfaceIndex $using:InterfaceIndex}

### Prompt to exit

Read-Host -Prompt Verify Changes, Then Press Enter to Exit




