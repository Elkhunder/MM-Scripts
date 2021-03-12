###Version 3###
###Added propmt for printer name and assigning name to a variable###
###Added changing default printer to the newly named local printer###
###Can't get set default printer to work when using invoke-command###


Do
{


### Create PSSession to user inputted TermID and assign it to a variable

$TermID = Read-Host -Prompt 'Input TermID'
$S = New-PSSession $TermID


### Pause to allow PSSession to connect prior to continuing

Start-Sleep -Seconds 3


### Get list of printer names, prompts for user input to continue and renames specified printer providing another list of printers verifying that the name was changed.
Enter-PSSession $S

Get-Printer | Format-Table -AutoSize
Read-Host -Prompt "Press any ket to continue or CTRL+C to quit"
Rename-Printer -Name 'HP LaserJet 600 M603 UPD PS' -NewName "LOCAL"
Get-Printer | Format-Table -AutoSize
$DefaultPrinter = Get-WmiObject Win32_Printer -Filter "Name = 'LOCAL'"
$DefaultPrinter.SetDefaultPrinter()

### Close any open PSSessions

Get-PSSession | Remove-PSSession
Get-PSSession
Read-Host -Prompt 'PSSession has been closed, press any key to exit'

### Set Variable for Do While Loop 

$repeat = Read-Host -Prompt 'Would you like to enter another TermID?  Enter Y for Yes and N for No'

}While ($repeat -eq 'Y')

