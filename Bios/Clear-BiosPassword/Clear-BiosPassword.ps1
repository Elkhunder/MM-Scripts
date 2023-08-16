<#

-Split by comma

Documentation
  Dell:
    User Guide: https://www.dell.com/support/manuals/en-us/command-powershell-provider/dcpp_2.7/introduction-to-dell-command-powershell-provider-27?guid=guid-80a7a07a-2643-4156-a275-a06f90f85e35&lang=en-us
    Reference Guide: https://www.dell.com/support/manuals/en-us/command-powershell-provider/dcpp_rg_2.7/introduction-to-dell-command-powershell-provider-27?guid=guid-80a7a07a-2643-4156-a275-a06f90f85e35&lang=en-us
  HP:
    Bios and Device Features: https://developers.hp.com/hp-client-management/doc/bios-and-device
#>
Write-Host "Computers: $Computers"
Write-Host "Scope: $Scope"
Write-Host "Bios Password:" $BiosPassword.EncryptedString
#Save Script Path to Variable
$ScriptPath = $MyInvocation.MyCommand.Path
#Set Current Location to Script Path
Set-Location -Path (Split-Path $ScriptPath)
#Import Custom Functions
Import-Module "..\..\CustomFunctions\CustomFunctions.ps1"
#Assign global variables
# $Scope = New-ListBox -TitleText "Scope" -LabelText "Where would you like to run the script" -ListBoxItems Local,Remote
#Set Bios Password to encrypted string
# $BiosPassword = New-CustomInput -LabelText "Input Bios Password" -AsEncryptedString
#Remove bios password and exit if local scope is selected
if($Scope -eq "Local"){
  $Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
  # Update-Dependencies -ExecutionPolicy "RemoteSigned" -RepositoryName "PSGallery" -RepositoryPolicy "Trusted"
  #Check for device manufacturer
  # if($Manufacturer -like "dell*"){
  #   #Install Dell PS Module
  #   # Update-Dependencies -ModuleNames "DellBIOSProvider"
  # }
  # if($Manufacturer -like "HP*"){
  #   #Install HP PS Module
  #   # Update-Dependencies -ModuleNames "HPCMSL"
  # }
  #Remove bios password
  Remove-BiosPassword -BiosPassword $BiosPassword -Manufacturer $Manufacturer
  Exit
}

# $UserFile = New-ListBox -TitleText "Import Computer Names" -LabelText "Would you like to use a file." -ListBoxItems Yes,No
# #Check if yes was selected
# if(($UserFile.DialogResult -eq 'OK') -and ($UserFile.SelectedItems -eq "Yes")){
#   #Prompt for file
#   $File = New-FileBrowser
#   #Save content to variable
#   $Computers = Get-Content $File.FileName
# } else {
#   #Prompt for computer names
#   $Computers = New-CustomInput -LabelText "Type a comma seperated list of computer names"
#   #Split string of computer names by comma or space into an array
#   $Computers = [regex]::Split($Computers, "[,\s]+")
# }
foreach ($Computer in $Computers) {
  write-host $Computer
  #Create PSSession
  $s = New-PSSession -ComputerName $Computer
  #Import custom commands into established session
  Invoke-Command -Session $s -FilePath "..\..\CustomFunctions\CustomFunctions.ps1"
  #Main script block to remove bios password
  Invoke-Command -Session $s -ScriptBlock {
    $Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
    Update-Dependencies -ExecutionPolicy "RemoteSigned" -RepositoryName "PSGallery" -RepositoryPolicy "Trusted" -PackageProviders "NuGet","PowerShellGet" -Verbose
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
    Remove-BiosPassword -BiosPassword $using:BiosPassword.EncryptedString -EncryptionKey $using:BiosPassword.EncryptionKey -Manufacturer $Manufacturer
  }
  #Remove PSSession
  Remove-PSSession -Session $s
}
if($BiosPassword){
  Remove-Variable "BiosPassword"
}
