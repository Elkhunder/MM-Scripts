
### Prompt for list of computers
$computers = Read-Host -Prompt 'Enter Term ID, if multiples seperate with ,'
### Split list of computers using , as the seperator
$computers = $computers -split ','
### Prompt for credentials
$credential = $host.ui.PromptForCredential("Need credentials", "Please enter your user name and password.", "", "NetBiosUserName")

foreach ($computer in $computers) {
  try
    {
    Write-Host Pulling a List of Connections...
    ### Pull a list of Network Connection Profiles
    Invoke-Command -ComputerName $computer -Credential $credential -ScriptBlock {Get-NetConnectionProfile}
    ### Prompt for Interface Index
    $interfaceIndex = Read-Host -Prompt 'Enter Interface Index'
    ### Change Network Category to Private for specified Interface Index
    Invoke-Command -ComputerName $computer -Credential $credential -ScriptBlock {Set-NetConnectionProfile -InterfaceIndex $using:interfaceIndex -NetworkCategory Private}
    Write-Host Pulling Connection Info...
    ###Re-Pull Connection Info to Verify Changes
    Invoke-Command -ComputerName $computer -Credential $credential -ScriptBlock {Get-NetConnectionProfile -InterfaceIndex $using:interfaceIndex}
    }
  catch
    {
    Write-Host 'An error occurred'
    Write-Host $_
    }
}
### Prompt to exit
Read-Host -Prompt 'Verify Changes, Then Press Enter to Exit'




