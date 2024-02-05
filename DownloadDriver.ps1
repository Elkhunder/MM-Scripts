#requires -version 5
<#
.SYNOPSIS
  Downloads, copies and extracts driver files to a specified computer[s].

.PARAMETER ComputerName
  One or more computer names to copy driver files to.

.INPUTS
  None
  
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Jonathon Sissom
  Creation Date:  1/22/2024
  Purpose/Change: Initial script development
.EXAMPLE
  .\DownloadDrivers.ps1 -ComputerName Computer1,Computer2

  Downloads drivers to Computer1 and Computer2 and prompts the user to select a folder to copy the files to.

.EXAMPLE
  .\SystemFileScan.ps1 -ComputerName Computer1

  Downloads drivers to Computer1 and copies them to the default location C:\Users\Public\Downloads.
#>
#---------------------------------------------------------[Script Parameters]------------------------------------------------------

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string[]]
    $ComputerName,
    [Parameter(Mandatory=$true)]
    [pscredential]
    $Credential = (Get-Credential)
    # [switch]
    # $PromptFolder
)

#---------------------------------------------------------[C# Code]----------------------------------------------------------------
# $code = @"
# using System;
# using System.Windows.Forms;

# public class Win32Window : IWin32Window
# {
#     public Win32Window(IntPtr handle)
#     {
#         Handle = handle;
#     }

#     public IntPtr Handle { get; private set; }
# }
# "@

#     if (-not ([System.Management.Automation.PSTypeName]'Win32Window').Type) {
#         Add-Type -TypeDefinition $code -ReferencedAssemblies System.Windows.Forms.dll -Language CSharp
#     }

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
Add-Type -AssemblyName System.Windows.Forms
$url = "https://downloadmirror.intel.com/812775/WiFi-23.20.0-Driver64-Win10-Win11.zip"
$dest = "C:\Users\Public\Downloads"

# $owner = [Win32Window]::new([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

# if($PromptFolder) {
#     $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
#     $FolderBrowser.SelectedPath = $PromptFolder
#     $FolderBrowser.ShowNewFolderButton = $true
#     $FolderBrowser.Description = "Select a folder to copy drivers to."
#     $FolderBrowser.ShowDialog($owner) | Out-Null
#     $dest = $FolderBrowser.SelectedPath
# }
Write-Log "Copying drivers to $dest" -LogPath $LogPath -ToOut

#Set Error Action to Silently Continue
$ErrorActionPreference = "Inquire"

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Any Global Declarations go here

#-----------------------------------------------------------[Functions]------------------------------------------------------------

# Log helper function
Function Write-Log {
    Param(
        [string]$Message,
        [string]$LogPath,
        [switch]$ToFile = $false,
        [switch]$ToOut = $false
        )      
        $logMessage = "$(Get-Date -Format o) | $Message" 
        if ($ToFile){
            $logMessage | Out-File -Append $LogPath
        }
        elseif ($ToOut) {
            $logMessage | Write-Output
        }
    }
Function Test-RemoteConnection {
  Param ([string]$ComputerName)

  Begin {
    Write-Log "Testing remote connection to $ComputerName..." -LogPath $LogPath -ToOut
  }

  Process {
    Try {
        if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
            Write-Log "$Computer is reachable." -LogPath $LogPath -ToOut
            return $true
        }
        else {
            Write-Log "$Computer is not reachable or does not respond to ping." -LogPath $LogPath -ToOut
            return $false
        }
    }
    Catch {
        Write-Log "$Computer could not be reached or connection failed: $($_.Exception.Message)" -LogPath $LogPath -ToOut
        return $false
    }
  }

  End {
    if ($?) {
      Write-Log "Connection test completed." -LogPath $LogPath -ToOut
    }
  }

}

Function Get-DriverFiles {

    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$true)][System.IO.FileInfo]$dest,
        [Parameter(Mandatory=$true)][string]$url
    )
    Write-Log "Downloading drivers to $ComputerName" -LogPath $LogPath -ToOut
    Invoke-Command -Session $Session -ScriptBlock {
        Start-BitsTransfer -Source $using:url -Destination $using:dest
        #unzip file
        Expand-Archive -Path "$using:dest/WiFi-23.20.0-Driver64-Win10-Win11.zip" -DestinationPath $using:dest -Force
        #remove zip file
        Remove-Item -Path "$using:dest/WiFi-23.20.0-Driver64-Win10-Win11.zip" -Force
    }
    Write-Log "Drivers downloaded to $ComputerName at $dest/WiFi-23.20.0-Driver64-Win10-Win11" -LogPath $LogPath -ToOut
}

#---------------------------------------------------------[Script Start]-----------------------------------------------------------

foreach ($Computer in $ComputerName) {
    #Test remote connection
    if (Test-RemoteConnection -ComputerName $Computer) {
      Write-Log "Connecting to $ComputerName" -LogPath $LogPath -ToOut
      $Session = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue
      Write-Log "Connected to $ComputerName" -LogPath $LogPath -ToOut
        if ($Session) {
            Get-DriverFiles -Session $Session -dest $dest -url $url
            Remove-PSSession -Session $Session -ErrorAction SilentlyContinue
            Write-Log "Disconnected from $ComputerName" -LogPath $LogPath -ToOut
        }
    }
}

