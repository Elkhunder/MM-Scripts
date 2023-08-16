<#
Documentation
      Dell:
        User Guide: https://www.dell.com/support/manuals/en-us/command-powershell-provider/dcpp_2.7/introduction-to-dell-command-powershell-provider-27?guid=guid-80a7a07a-2643-4156-a275-a06f90f85e35&lang=en-us
        Reference Guide: https://www.dell.com/support/manuals/en-us/command-powershell-provider/dcpp_rg_2.7/introduction-to-dell-command-powershell-provider-27?guid=guid-80a7a07a-2643-4156-a275-a06f90f85e35&lang=en-us
      HP:
        Bios and Device Features: https://developers.hp.com/hp-client-management/doc/bios-and-device
#>
function New-EncryptionKey{
  <#
    .SYNOPSIS
    Creates new encryption key

    .DESCRIPTION
    Creates new encryption key to be passed to the Convert-FromSecureString commandlet

    .PARAMETER Path
    The path where the key file is saved

    .EXAMPLE
    New-EncryptionKey -Path "~\encryption.key"
  #>
  param(
    [string]$Path
  )
  #Initialize a 32 bit byte array
  $EncryptionKey = New-Object Byte[] 32
  #Create encryption key
  [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($EncryptionKey)
  #Save encryption key to provided file path
  if($Path){
    $EncryptionKey | Out-File $Path
  } else {
    return $EncryptionKey
  }
}
function New-ListBox{
  <#
    .SYNOPSIS
    Creates List Box

    .DESCRIPTION
    -Creates list box for getting user selected data
    .PARAMETER TitleText
    The title of the list box

    .PARAMETER LabelText
    The description message for the list box

    .PARAMETER ListBoxItems
    The items to put in the list box to be selected

    .EXAMPLE
    New-ListBox -TitleText "Scope" -LabelText "Where would you like to run the script" -ListBoxItems Local,Remote
  #>
  Param(
    [string[]]$TitleText,
    [string[]]$LabelText,
    [string[]]$ListBoxItems
  )
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing

  $form = New-Object System.Windows.Forms.Form
  $form.Text = $TitleText
  $form.Size = New-Object System.Drawing.Size(300,200)
  $form.StartPosition = 'CenterScreen'

  $okButton = New-Object System.Windows.Forms.Button
  $okButton.Location = New-Object System.Drawing.Point(75,120)
  $okButton.Size = New-Object System.Drawing.Size(75,23)
  $okButton.Text = 'Ok'
  $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $form.AcceptButton = $okButton
  $form.Controls.Add($okButton)

  $cancelButton = New-Object System.Windows.Forms.Button
  $cancelButton.Location = New-Object System.Drawing.Point(150,120)
  $cancelButton.Size = New-Object System.Drawing.Size(75,23)
  $cancelButton.Text = 'Cancel'
  $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
  $form.CancelButton = $cancelButton
  $form.Controls.Add($cancelButton)

  $label = New-Object System.Windows.Forms.Label
  $label.Location = New-Object System.Drawing.Point(10,20)
  $label.Size = New-Object System.Drawing.Size(280,20)
  $label.Text = $LabelText
  $form.Controls.Add($label)

  $listBox = New-Object System.Windows.Forms.ListBox
  $listBox.Location = New-Object System.Drawing.Point(10,40)
  $listBox.Size = New-Object System.Drawing.Size(260,20)
  $listBox.Height = 80

  foreach ($ListboxItem in $ListBoxItems) {
    [void] $listBox.Items.Add($ListboxItem)
  }

  $form.Controls.Add($listBox)

  $form.Topmost = $true
  $result = $form.ShowDialog()

  if($result -eq [System.Windows.Forms.DialogResult]::Cancel){
    Write-Host "Cancel was selected, exiting program."
    Start-Sleep -Seconds 3
    exit
  }

  return $listBox.SelectedItem
}

function New-FileBrowser{
  <#
    .SYNOPSIS
    Creates New File Browser Window

    .DESCRIPTION
    -Prompts with file browser window to get content from a file input
    .PARAMETER InitialDirectory
    The path that opens when the browser window opens, default is current users desktop
    .PARAMETER Filter
    File filter to display only certain types of files, default is text and csv

    .EXAMPLE
    New-FileBrowser -InitialDirectory "Documents" -Filter 'CSV Files (*.csv)|*.csv'
  #>
  param (
  [string[]]$InitialDirectory = 'Desktop',
  [string[]]$Filter = 'TXT Files (*.txt)|*.txt|CSV Files (*.csv)|*.csv'
  )

  Add-Type -AssemblyName System.Windows.Forms
  $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath($InitialDirectory)
    Filter = $Filter
  }
  $result = $FileBrowser.ShowDialog()

  if($result -eq [System.Windows.Forms.DialogResult]::Cancel){
    Write-Host "Cancel was selected, exiting program."
    Start-Sleep -Seconds 3
    exit
  }
  return $FileBrowser.FileName
}

function New-CustomInput{
  <#
    .SYNOPSIS
    Creates Input Text Box

    .DESCRIPTION
    -Creates input text box for getting user input
    .PARAMETER LabelText
    The text box label
    .PARAMETER AsSecureString
    Text as a secure string
    .PARAMETER AsEncryptedString
    Text as an encrypted string
    .NOTES
    Function Returns
    -Default
      Inputed Text
    -AsSecureString
      Returns inputed text as secure string
    -AsEncryptedString
      Returns encryption key and inputed text encrpted string file paths
  #>
  [cmdletbinding(DefaultParameterSetName="plain")]
  [OutputType([system.string],ParameterSetName='plain')]
  [OutputType([system.security.securestring],ParameterSetName='secure')]

  Param(
    [Parameter(ParameterSetName = "secure")]
    [Parameter(ParameterSetName = "encrypted")]
    [Parameter(HelpMessage = "Enter the title for the input box.",
    ParameterSetName="plain")]

    [ValidateNotNullOrEmpty()]
    [string[]]$LabelText = "Input Text",

    [Parameter(HelpMessage = "Use to mask the entry and return a secure string.",
    ParameterSetName = "secure")]
    [switch]$AsSecureString,

    [Parameter(HelpMessage = "Use to mask the entry and return an encrypted string.",
    ParameterSetName = "encrypted")]
    [switch]$AsEncryptedString
  )
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing

  $form = New-Object System.Windows.Forms.Form
  $form.Text = 'Data Entry Form'
  $form.Size = New-Object System.Drawing.Size(300,200)
  $form.StartPosition = 'CenterScreen'

  $okButton = New-Object System.Windows.Forms.Button
  $okButton.Location = New-Object System.Drawing.Point(75,120)
  $okButton.Size = New-Object System.Drawing.Size(75,23)
  $okButton.Text = 'OK'
  $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $form.AcceptButton = $okButton
  $form.Controls.Add($okButton)

  $cancelButton = New-Object System.Windows.Forms.Button
  $cancelButton.Location = New-Object System.Drawing.Point(150,120)
  $cancelButton.Size = New-Object System.Drawing.Size(75,23)
  $cancelButton.Text = 'Cancel'
  $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
  $form.CancelButton = $cancelButton
  $form.Controls.Add($cancelButton)

  $label = New-Object System.Windows.Forms.Label
  $label.Location = New-Object System.Drawing.Point(10,20)
  $label.Size = New-Object System.Drawing.Size(280,20)
  $label.Text = $LabelText
  $form.Controls.Add($label)

  if ($AsSecureString -or $AsEncryptedString){
    $textBox = New-Object System.Windows.Forms.MaskedTextBox
    $textBox.PasswordChar = '*'
  } else {
    $textBox = New-Object System.Windows.Forms.TextBox
  }
  $textBox.Location = New-Object System.Drawing.Point(10,40)
  $textBox.Size = New-Object System.Drawing.Size(260,20)
  $form.Controls.Add($textBox)

  $form.Topmost = $true

  $form.Add_Shown({$textBox.Select()})
  $result = $form.ShowDialog()
  $text = $textBox.Text
  if($result -eq [System.Windows.Forms.DialogResult]::Cancel){
    Write-Host "Cancel was selected, exiting program."
    Start-Sleep -Seconds 3
    exit
  }

  if($result -eq [System.Windows.Forms.DialogResult]::OK -and $AsSecureString){
    return ConvertTo-SecureString $text -AsPlainText -Force
  }
  if($result -eq [System.Windows.Forms.DialogResult]::OK -and $AsEncryptedString){
    # New-EncryptionKey -Path "~\encryption.key"
    $EncryptionKey = New-EncryptionKey
    $EncryptedString = ConvertTo-SecureString $text -AsPlainText -Force |
      ConvertFrom-SecureString -Key $EncryptionKey
        # | Out-File -FilePath "~\encryptedstring.encrypted"
    # $EncryptionKey = "~\encryption.key"
    # $EncryptedString = "~\encryptedstring.encrypted"
    Return @{
      EncryptionKey = $EncryptionKey;
      EncryptedString = $EncryptedString
    }
  }
  return $text
}

function New-ElevatedPrompt{
  <#
    .SYNOPSIS
    Elevates Script in New Powershell Session

    .DESCRIPTION
    -Checks to see if script is already running in an elevated session
    -Launches new elevated powershell session and calls script
    .PARAMETER Path
    The path of the script file

    .PARAMETER Credentials
    Provided credentials, not currently utilizing
  #>
  param(
    [Parameter(HelpMessage = "The Path For the Current Script File")]
    [string]$ScriptPath,
    [Parameter(HelpMessage = "The Path of Functions to import")]
    [string]$FunctionPath
  )
  #Check if current powershell session is running elevated
  if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Write-Host "Prompt is not Elevated, Elevating Prompt.  Enter your secondary credentials in the UAC prompt"
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $ScriptBlock = {
      <#
      Gets username of the currently logged on user not the one that is running the script.
      This is done to return the primary level-2 account of the currently logged in user,
      as at this point the script will be running with their secondary level-2 account
      #>
      $UserName = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object username).username
      # #Get primary level-2 account credentials
      $Credential = Get-Credential -UserName $UserName -Message "'Provide your Level-2 credentials.'"
      <#
      Map share drive with the provided primary level-2 credentials.
      Without this the script won't have access to the share path when the script launches
      #>
      New-PSDrive -Name 'T' -PSProvider 'FileSystem' -Root '\\corefs.med.umich.edu\shared2' -Credential $Credential | Out-Null
    }
    #Specify command line arguments
    $CommandLine = "-NoExit", "-Command $ScriptBlock"
    <#
    Start new elevated powershell process with command line arguments and the script path passed in as arguments
    Im not 100% sure why this works and calls the script?
    Potentially after the command line arguments are called it passes in the full script path which calls then executes the script
    #>
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "$CommandLine", "$ScriptPath"
    #Exit current unelevated powershell session
    Exit
  }
}
}

function Update-Dependencies{
  <#
    .SYNOPSIS
    Installs Script Dependencies.

    .DESCRIPTION
    Installs or sets the following script dependencies:
      Sets the Execution Policy
      Sets Repository Installation Policy
      Installs/Updates Package Providers
      Installs Modules
      Imports Installed Modules
    Depencies will only be installed if the necessary params are provided

    .PARAMETER ExecutionPolicy
    Specifies the execution policy value

    .PARAMETER RepositoryName
    Specifies the repository name to set the installation policy for

    .PARAMETER RepositoryPolicy
    Specifies the installation policy for the Repository

    .PARAMETER ModuleNames
    Specifies the module names to be verified and installed

    .PARAMETER PackageProviders
    Specifies the package providers to install or update
  #>

  param(
    [string]$ExecutionPolicy,
    [string]$RepositoryName,
    [string]$RepositoryPolicy,
    [string[]]$ModuleNames,
    [string[]]$PackageProviders,
    [switch]$Verbose
  )
  #Check if package provider parameter was provided
  if($PackageProviders){
    $_nugetUrl = "https://api.nuget.org/v3/index.json"
    $packageSources = Get-PackageSource
    if(@($packageSources).Where{$_.location -eq $_nugetUrl}.count -eq 0){
      Register-PackageSource -Name MyNuGet -Location $_nugetUrl -ProviderName NuGet -Force
    }
    # if(!(Get-PackageProvider -Name))
    foreach($PackageProvider in $PackageProviders){
      #Get locally installed provider version
      if($Verbose){
        Write-Host "Package Provider: $PackageProvider"
        Write-Host "Getting locally installed version ..."
      }
      $LocalVersion = Get-PackageProvider -Name $PackageProvider -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
      if($Verbose){
        Write-Host "Locally installed version: $LocalVersion ..."
      }
      #Get most recent version from repository
      if($Verbose){
        Write-Host "Getting version from repository..."
      }
      $RepositoryVersion = Find-PackageProvider -Name $PackageProvider -Force | Select-Object -ExpandProperty Version
      if($Verbose){
        Write-Host "Repository version: $RepositoryVersion ..."
      }
      #Check if local version is less than repository version
      if($LocalVersion -lt $RepositoryVersion){
        #Install package provider from repository and save the version to a variable
        if($Verbose){
          Write-Host "Installing package provider version: $RepositoryVersion ..."
        }
        $InstallationVersion = Install-PackageProvider -Name $PackageProvider -Force
        $InstallationVersion
        $InstallationVersion = $InstallationVersion | Select-Object -ExpandProperty Version
        #Display the package provider version that was installed
        if($Verbose){
          Write-Host "$PackageProvider updated to version: $InstallationVersion ..."
          Write-Host "Importing new version ..."
        }
        #Import newly installed package provider and save version to a variable
        $ImportVersion = Import-PackageProvider -Name $PackageProvider -RequiredVersion $RepositoryVersion -Force
        # | Select-Object -ExpandProperty Version
        #Display the package provider version that was imported
        if($Verbose){
          Write-Host "$PackageProvider Version: $ImportVersion imported successfully ..."
        }
      } else {
        #Display installed version
        if($Verbose){
          Write-Host "$PackageProvider Version: $LocalVersion ..."
        }
      }
    }
  }
  #Check if execution policy parameter was provided
  if($ExecutionPolicy){
    # Check if the Execution Policy is alread set to the specified policy
    if((Get-ExecutionPolicy) -ne $ExecutionPolicy){
      #Set execution policy to specified policy
      Set-ExecutionPolicy $ExecutionPolicy -Force -Scope Process
      Write-Host "Execution Policy: $ExecutionPolicy..."
    } else {
      Write-Host "Execution Policy: $ExecutionPolicy ..."
    }
  }

  # Check if repository name parameter was provided
  if($RepositoryName){
    # Check if the repository policy is already set to the specified policy
    if((Get-PSRepository -Name $RepositoryName).InstallationPolicy -ne $RepositoryPolicy){
      #Set repository installation policy to the specified policy
      Set-PSRepository -Name $RepositoryName -InstallationPolicy $RepositoryPolicy
      Write-Host "$RepositoryName Installation Policy: $RepositoryPolicy..."
    } else {
      Write-Host "$RepositoryName Installation Policy: $RepositoryPolicy ..."
    }
  }

  #Check if Module Name parameter was provided
  if($ModuleNames){
    foreach($ModuleName in $ModuleNames){
      #Check if specified module is already installed
      if(Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue){
        Write-Host "Module Installed: $ModuleName..."
      } else {
        #Install the specified module
        Install-Module -Name $ModuleName -Scope CurrentUser -AcceptLicense
        Write-Host "Module Installed: $ModuleName..."
      }
      # Check if the specified module is already imported
      if(Get-Module -Name $ModuleName){
        Write-Host "Module Imported: $ModuleName..."
      } else {
        #Import the specified module
        Import-Module $ModuleName
        Write-Host "Module Imported: $ModuleName..."
      }
    }
  }
}

function Remove-BiosPassword{
  <#
    .SYNOPSIS
    Removes a Dell Bios Password using the Dell PowerShell Module

    .DESCRIPTION
      Checks if Bios Password is set
      Removes Bios Password
      Verifies Removal of Bios Password

    .PARAMETER BiosPassword
    The Current Bios Password
    .PARAMETER Scope
    Where the script is being run, Local or Remote
    .PARAMETER Manufacturer
    The Manufacturer of the device
    .NOTES
    Documentation
      Dell:
        Bios Password Features: https://www.dell.com/support/kbdoc/en-us/000146358/dell-command-powershell-provider-bios-passwords-feature
      HP:
        Bios Password Features:
          Clear: https://developers.hp.com/hp-client-management/doc/Clear-HPBIOSSetupPassword
          Get: https://developers.hp.com/hp-client-management/doc/Get-HPBIOSSetupPasswordIsSet
          Set: https://developers.hp.com/hp-client-management/doc/Set-HPBIOSSetupPassword

  #>
  param(
    [string]$BiosPassword,
    [array]$EncryptionKey,
    [string]$Scope,
    [string]$Manufacturer,
    [switch]$Verbose
  )
  if($Verbose){
    Write-Host "Verbose Logging: True"
    Write-Host "Running Bios Removal Function..."
    Write-Host "Current Variables:"
    if($Scope){
      Write-Host "Scope Set: True"
    } else {
      Write-Host "Scope Set: False"
    }
    if($Manufacturer){
      Write-Host "Manufacturer Set: True"
    } else {
      Write-Host "Manufacturer Set: False"
    }
    if($BiosPassword){
      Write-Host "Bios Password Set: True"
    } else {
      Write-Host "Bios Password Set: False"
    }
    if($EncryptionKey){
      Write-Host "Encrytpion Key Set: True"
    } else {
      Write-Host "Encryption Key Set: False"
    }
  }
  if($EncryptionKey){
    # $EncryptionKey = Get-Content $EncryptionKey
    if($Verbose){
      if($EncryptionKey){
        Write-Host "Decrypting Bios Password ..."
      }
    }
    [securestring]$BiosPassword = ConvertTo-SecureString -String $BiosPassword -Key $EncryptionKey
    if($Verbose){
      Write-Host "Bios Password Decrypted: True"
    }
  }
  #Check manufacturer
  if($Manufacturer -like "dell*"){
    #Set location to the dell ps module ps drive
    Set-Location DellSMBios:
    #Check to see if bios password is set and save to variable
    $BiosPasswordSet = Get-ChildItem DellSmbios:\Security\IsAdminPasswordSet
    #If bios password is set
    if($BiosPasswordSet.CurrentValue -eq "True"){
      Write-Host "Bios Password is set, Attempting to remove bios password ..."
      #Remove bios password by setting to an empty string
      #Documentation:
      Set-Item DellSmbios:\Security\AdminPassword -Value ""  -PasswordSecure $BiosPassword
      #Re-Check if bios password is set to confirm removal
      $BiosPasswordSet = Get-ChildItem DellSmbios:\Security\IsAdminPasswordSet
      #Display current value
      Write-Host "Bios Password is set: " $BiosPasswordSet.CurrentValue
    }else{
      #Display current value
      Write-Host "Bios Password is set: " $BiosPasswordSet.CurrentValue
    }
  }

  if($Manufacturer -like "hp*"){
    #Convert bios password from secure string to plaintext
    $BiosPasswordPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($BiosPassword))
    #Check if bios password is set
    if(Get-HPBIOSSetupPasswordIsSet){
      Write-Host "Bios Password is set, Attempting to remove bios password ..."
      #Remove bios password
      Clear-HPBIOSSetupPassword -Password $BiosPasswordPlainText
      #Confirm that bios password was removed
      Write-Host "Bios Password is set: "(Get-HPBIOSSetupPasswordIsSet)
    } else {
      <#
      For testing purposes you can enable to below line to reset the bios password if it isn't already set.
      Set-HPBIOSSetupPassword -NewPassword "yous2323"
      #>
      #Confirm that bios password is not set
      Write-Host "Bios Password is set: "(Get-HPBIOSSetupPasswordIsSet)
    }
  }
  #Clean up variables
  if($EncryptionKey){
    Remove-Variable -Name "EncryptionKey"
  }
  if($BiosPasswordPlainText){
    Remove-Variable -Name "BiosPasswordPlainText"
  }
  if($BiosPassword){
    Remove-Variable -Name "BiosPassword"
  }
}