#Get Input, TermId's must be seperated by commas 
$_TermIdList = Read-Host "Enter TermId's, seperated by commas with no spaces.  There is a limit of 28 termid's at one time"
$_TermIdList
psexec \\$_TermIdList -s cscript c:\wsmgmt\bin\setprinters-win7.vbs
Read-Host -Prompt "Press Enter to Exit"