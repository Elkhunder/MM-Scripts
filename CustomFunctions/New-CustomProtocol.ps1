function New-CustomProtocol {
  [CmdletBinding()]
  param (
    # Name of the file to search for
    [Parameter(Mandatory = $true)]
    [String]
    $FileName,
    # Path to search for the file
    [Parameter(Mandatory = $true)]
    [String]
    $SearchPath,
    # Name of the custom URL protocol
    [Parameter(Mandatory = $true)]
    [String]
    $ProtocolName,
    # Switch to run as admin
    [Parameter(Mandatory = $false)]
    [switch]
    $AsAdmin
  )
  Import-Module ./CustomFunctions/CustomFunctions.ps1
  
  New-FileBrowser -InitialDirectory 'Program Files' -Filter 'All Files (*.*)|*.*'

  # Use Get-ChildItem to search for the file
  $file = Get-ChildItem -Path $SearchPath -Filter $FileName -ErrorAction SilentlyContinue
  if ($file) {
    # Modify the protocol name if the -AsAdmin switch is specified
    if ($AsAdmin) {
      $ProtocolName = "$($ProtocolName)-admin"
      Write-Verbose "Protocol name updated: ${ProtocolName}"
    }
    # Create the custom URL protocol
    New-Item `
      -Path "HKLM:\Software\Classes\$ProtocolName" `
      -Force |
      Out-Null

    New-ItemProperty `
      -Path "HKLM:\Software\Classes\$ProtocolName" `
      -Name "URL Protocol" `
      -Value "" `
      -PropertyType "String" `
      -Force |
      Out-Null
    New-Item `
      -Path "HKLM:\Software\Classes\$ProtocolName\shell\open\command" `
      -Force |
      Out-Null
    # Use Start-Process with the -Verb parameter set to "runas" to run the application with administrative rights if the -AsAdmin switch is specified
    if ($AsAdmin) {
      New-ItemProperty `
        -Path "HKLM:\Software\Classes\$ProtocolName\shell\open\command" `
        -Name "(default)" `
        -Value "powershell -NoProfile -Command ""& Start-Process '$($file.FullName)' -Verb runas" `
        -PropertyType "String" `
        -Force |
        Out-Null
    }

    New-ItemProperty `
      -Path "HKLM:\Software\Classes\$ProtocolName\shell\open\command" `
      -Name "(default)" `
      -Value "$($file.FullName) '%1'" `
      -PropertyType "String" `
      -Force |
      Out-Null
    # Return the full path of the file
    return $file.FullName
  } else {
    # Return an error message if the file was not found
    $_
  }
}
New-CustomProtocol -FileName 'devenv.exe' -SearchPath 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\' -ProtocolName 'devenv'