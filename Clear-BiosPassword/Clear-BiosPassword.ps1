<#

-Split by comma

Documentation
  Dell:
    User Guide: https://www.dell.com/support/manuals/en-us/command-powershell-provider/dcpp_2.7/introduction-to-dell-command-powershell-provider-27?guid=guid-80a7a07a-2643-4156-a275-a06f90f85e35&lang=en-us
    Reference Guide: https://www.dell.com/support/manuals/en-us/command-powershell-provider/dcpp_rg_2.7/introduction-to-dell-command-powershell-provider-27?guid=guid-80a7a07a-2643-4156-a275-a06f90f85e35&lang=en-us
  HP:
    Bios and Device Features: https://developers.hp.com/hp-client-management/doc/bios-and-device
#>

#Save Script Path to Variable
$ScriptPath = $MyInvocation.MyCommand.Path
#Set Current Location to Script Path
Set-Location -Path (Split-Path $ScriptPath)
#Import Custom Functions
Import-Module '.\Functions.ps1'
#Check and Elevate Powershell Prompt if Necessary
New-ElevatedPrompt -Path $ScriptPath

#Set Bios Password to secure string
$BiosPassword = New-CustomInput -LabelText "Input Bios Password" -AsEncryptedString
#Get location script is being run
$Scope = New-ListBox -TitleText "Scope" -LabelText "Where would you like to run the script" -ListBoxItems Local,Remote
#Update dependencies
Update-Dependencies -ExecutionPolicy "RemoteSigned" -RepositoryName "PSGallery" -RepositoryPolicy "Trusted" -ModuleNames "DellBIOSProvider", "HPCMSL"

#Remove Bios Password and Exit if running locally
if ($Scope.Text -eq "Local"){
  Remove-BiosPassword -BiosPassword $BiosPassword
  Exit
}
#Prompt for list of computer names if running remotely
$userFile = New-ListBox -TitleText "Import Computer Names" -LabelText "Would you like to use a file." -ListBoxItems Yes,No
#Check if yes was selected
if(($userFile.DialogResult -eq 'OK') -and ($userFile.SelectedItems -eq "Yes")){
  #Prompt for file
  $file = New-FileBrowser
  #Save content to variable
  $computers = Get-Content $file.FileName
} else {
  #Prompt for computer names
  $computers = New-CustomInput -LabelText "Type a comma seperated list of computer names"
  #Split string of computer names by comma or space into an array
  $computers = [regex]::Split($computers, "[,\s]+")
}

foreach ($computer in $computers) {
  write-host $computer
  #Create PSSession
  $s = New-PSSession -ComputerName $computer
  #Import custom commands into established session
  Invoke-Command -Session $s -FilePath .\Functions.ps1
  #Main script block to remove bios password
  Invoke-Command -Session $s -ScriptBlock {
    $Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
    Update-Dependencies -ExecutionPolicy "RemoteSigned" -RepositoryName "PSGallery" -RepositoryPolicy "Trusted" -PackageProviders "NuGet","PowerShellGet"
    #Check for device manufacturer
    if($Manufacturer -like "dell*"){
      #Install Dell PS Module
      Update-Dependencies -ModuleNames "DellBIOSProvider"
    }
    if ($Manufacturer -like "HP*") {
      #Install HP PS Module
      Update-Dependencies -ModuleNames "HPCMSL"
    }
    #Remove Bios Password
    Remove-BiosPassword -BiosPassword $using:BiosPassword -Manufacturer $Manufacturer
  }
  #Remove PSSession
  Remove-PSSession -Session $s
}