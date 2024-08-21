<#

************************** Change Log ******************************
************************** Version 1 *******************************

** Initial Commit **

************************ Feature Requests **************************

Future - Add ability to choose if you want to export results to a file instead of have it written to console

#>

$userFile = Read-Host -Prompt 'Do you want to use a file for importing computer names? (Y/N)'
try {
  if($userFile -eq 'Y') {
    Do {

      Write-Host 'Place a text file on your desktop that contains the computer names'
      $filename = Read-Host -Prompt "Input filename w/o extension"
      $filePath = "C:\Users\$env:USERNAME\Desktop\$filename.txt"
      $testPath = Test-Path $filePath -PathType Leaf
      if ($testPath -eq "True") {continue}
      else {

        Write-Host 'The file was not found, or there was an error'
        Write-Host $_
      }
    }
    Until ($testPath -eq "True")

    $computers = Get-Content $filePath
    Write-Host $computers
  }

  if($userFile -eq 'N') {

    ### Prompt for list of computers and assign to the variable computers
    $computers = Read-Host -Prompt 'Enter Term ID, if multiples seperate with ,'
    ### Split list of computers using , as the seperator
    $computers = $computers -split ','
  }
} catch {

  Write-Host 'An error occured'
  Write-Host $_
}

### Prompt for credentials
$userLogin = (Read-Host -Prompt 'Enter your uniqname').ToLower()
if($userLogin -like 'umhs-*'){
  $userLogin = "UMHS/$username"
} else {
  $userLogin = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
}
$credentials = Get-Credential $userLogin -Message "Enter your password"

### TO DO Initialize headers for the CSV file



foreach ($computer in $computers) {
  try {
    $reachable = Test-Connection -TargetName $computer -BufferSize 16 -Count 1 -ea 0 -quiet

    ### Check to see if computer is reachable
    if ($reachable)
    {
        ### Get currently logged in users
        Write-Host `Pulling information from $computer ...`
        $userInstance = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $computer
        $userList = $userInstance.UserName
    }
    else
    {
        Write-Host `$computer is not reachable`
        return
    }

    ### Store the information in an array
    $Content = [PSCustomObject]@{
      TermID = $computer;
      Online = $reachable;
      LoggedOnUsers = $userList
    }
    # New-Object -TypeName PSObject -Property @{
    #     TermID = $computer
    #     Online = $reachable
    #     LoggedOnUsers = $userList
    # } | Select-Object TermID, Online, Printer

    }catch{
        Write-Host 'An error occured'
        Write-Host $_
        }
}
$Content | Export-Csv -Path .\UserList.csv -Append -NoTypeInformation