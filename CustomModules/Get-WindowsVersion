<#
.SYNOPSIS
Retrieves the Windows operating system version information for a list of specified computers.

.DESCRIPTION
The Get-WindowsVersion function queries the Windows version information from a list of computers, which can be provided directly or through a file. The function supports both local and remote computers, with the option to use secondary credentials for remote access. Results can be output to a file or displayed in the console.

.PARAMETER ComputerName
Specifies a list of computer names to query. This parameter accepts an array of strings. If used in conjunction with the UseInFile switch, an error will be raised.

.PARAMETER Credential
Provides credentials for authentication when accessing remote computers. This parameter expects a PSCredential object containing the username and password.

.PARAMETER UseInFile
Indicates that a file containing the list of computer names should be used instead of specifying them directly. A file dialog will prompt the user to select a CSV file.

.PARAMETER UseOutFile
Specifies that the results should be written to a file. A save file dialog will prompt the user to select the file path for saving the output.

.EXAMPLE
Get-WindowsVersion -ComputerName "Server1", "Server2" -Credential $myCred
Retrieves Windows version information for the specified computers using the provided credentials.

.EXAMPLE
Get-WindowsVersion -UseInFile
Prompts the user to select a file containing a list of computer names and retrieves their Windows version information.

.EXAMPLE
Get-WindowsVersion -ComputerName "Server1" -UseOutFile
Retrieves Windows version information for the specified computer and saves the results to a file.

.EXAMPLE
Get-WindowsVersion -UseInFile -UseOutFile
Prompts the user to select a file containing computer names and then saves the results to a specified output file.
#>
function Get-WindowsVersion{
    [CmdletBinding()]
    param (
        # List of computer names
        [Parameter()]
        [string[]]
        $ComputerName,

        # Secondary Credentials
        [Parameter()]
        [System.Management.Automation.Credential()]
        [PSCredential]$Credential,
        
        # Prompt for a file instead of using a list of computer names
        [switch]
        $UseInFile,

        # Write to file instead of console
        [switch]
        $UseOutFile
    )
    $WinVersionMap = @{
        '10240' = '1507'    # Windows 10, Version 1507
        '10586' = '1511'    # Windows 10, Version 1511
        '14393' = '1607'    # Windows 10, Version 1607 / Windows Server 2016, Version 1607
        '15063' = '1703'    # Windows 10, Version 1703
        '16299' = '1709'    # Windows 10, Version 1709
        '17134' = '1803'    # Windows 10, Version 1803
        '17763' = '1809'    # Windows 10, Version 1809 / Windows Server 2019, Version 1809
        '18362' = '1903'    # Windows 10, Version 1903
        '18363' = '1909'    # Windows 10, Version 1909 / Windows Server, Version 1909
        '19041' = '2004'    # Windows 10, Version 2004 / Windows Server, Version 2004
        '19042' = '20H2'    # Windows 10, Version 20H2 / Windows Server, Version 20H2
        '19043' = '21H1'    # Windows 10, Version 21H1
        '19044' = '21H2'    # Windows 10, Version 21H2
        '19045' = '22H2'    # Windows 10, Version 22H2
        '22000' = '21H2'    # Windows 11, Version 21H2
        '22621' = '22H2'    # Windows 11, Version 22H2
        '22631' = '23H2'    # Windows 11, Version 23H2
    }
    If ($UseInFile -and !$null -eq $ComputerName){
        Write-Error "Can not use ComputerName parameter and UseInFile switch together"
        return
    }
    if($UseInFile){
        Add-Type -AssemblyName System.Windows.Forms
        $Form = New-Object 'System.Windows.Forms.Form' -Property @{TopMost=$true}
        $File = New-Object System.Windows.Forms.OpenFileDialog
            $File.ShowHelp = $true
            $File.InitialDirectory = [Environment]::GetFolderPath('Desktop')
            $File.Filter = "CSV Files (*.csv)|*.csv"
            $File.FilterIndex = 1
            $File.CheckFileExists = $true
            
        #$FileDialog = $File.ShowDialog($Form)

        while ($file.ShowDialog($form) -ne [System.Windows.Forms.DialogResult]::OK) {
            # If the dialog result is not "OK", it must be "Cancel", so we prompt the user
            $response = [System.Windows.Forms.MessageBox]::Show("You pressed Cancel. Do you want to try again?", "File Selection", [System.Windows.Forms.MessageBoxButtons]::YesNo)
        
            # If the user selects "No" on the message box, exit the loop
            if ($response -eq [System.Windows.Forms.DialogResult]::No) {
                $manualEntryResponse = [System.Windows.Forms.MessageBox]::Show("Do you want to enter computers manually?", "Manual Entry", [System.Windows.Forms.MessageBoxButtons]::YesNo)
                if ($manualEntryResponse -eq [System.Windows.Forms.DialogResult]::No){
                    Write-Output "Operation cancelled by user."
                    return
                }
                else{
                    $ComputerName = Read-Host "Enter list of computer names"
                    break
                }
            }
        }
        
        # if ($file.FileName) {
        #     # If the user finally selected a file, proceed with your logic here
        #     Write-Host "Selected file: $($file.FileName)"
        # } else {
        #     Write-Host "No file selected."
        # }

        if ($File.FileName){
            [string[]]$ComputerName = $(Get-Content -Path $File.FileName)
            $message = "Getting windows version for:"
            foreach ($Computer in $ComputerName) {
                $message = $message + " " + $Computer
            }
            Write-Host $message
        }
        elseif ($ComputerName){
            $message = "Getting windows version for:"
            foreach ($Computer in $ComputerName) {
                $message = $message + " " + $Computer
            }
            Write-Host $message
        }
    }
    if (($ComputerName.Length -gt 1) -or ($ComputerName.Length -eq 1 -and !($ComputerName -contains '127.0.0.1' -or $ComputerName -contains 'localhost')) -and $null -eq $Credential){
        Write-Host "Credential $ComputerName : $($ComputerName.Length)"
        $Credential = $(Get-Credential -UserName "umhs\umhs-$([Environment]::UserName)" -Message "Enter Secondary Credentials")
    }
    $DeviceInfoList = @()

    foreach ($Computer in $ComputerName.Split(",").Trim()){
        if (Test-Connection -ComputerName $Computer -Count 1 -Quiet){
            try {
                if($Computer -eq 'localhost' -or $Computer -eq '127.0.0.1'){
                    Write-Host "Computer is localhost"
                    $Win32_OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem

                    $DeviceInfo = [PSCustomObject]@{
                        'Computer' = $Computer
                        'OS Name' = $Win32_OperatingSystem.Caption
                        'OS Version' = $WinVersionMap[$Win32_OperatingSystem.BuildNumber]
                    }

                    $deviceInfoList += $DeviceInfo
                }
                else{
                    Write-Host "Computer is not local host"
                    $Session = New-CimSession -Credential $Credential -ComputerName $Computer
                    $Win32_OperatingSystem = Get-CimInstance -CimSession $Session -ClassName Win32_OperatingSystem

                    $DeviceInfo = [PSCustomObject]@{
                        'Computer' = $Computer
                        'OS Name' = $Win32_OperatingSystem.Caption
                        'OS Version' = $WinVersionMap[$Win32_OperatingSystem.BuildNumber]
                    }

                    $deviceInfoList += $DeviceInfo
                }
            }
            catch {
                Write-Error "Failed to retrieve OS Information from $Computer. Error: $_"
            }
        }
        else {
            Write-Error "$Computer is unreachable"
        }
    }
    if ($UseOutFile){
        Add-Type -AssemblyName System.Windows.Forms
        $Form = New-Object System.Windows.Forms.Form -Property @{TopMost = $true}
        $File = New-Object System.Windows.Forms.SaveFileDialog
            $File.ShowHelp = $true
            $File.InitialDirectory = [Environment]::GetFolderPath('Desktop')
            $File.Filter = "CSV Files (*.csv)|*.csv"
            $File.FilterIndex = 1
            $File.OverwritePrompt = $true
        $FileDialog = $File.ShowDialog($Form)

        $DeviceInfoList | Format-Table -AutoSize | Out-File -FilePath $File.FileName
    }
    return $DeviceInfoList | Format-Table -AutoSize
}