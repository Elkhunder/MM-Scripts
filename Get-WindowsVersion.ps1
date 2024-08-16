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

$DeviceInfoList = @()
$User = ((Get-CimInstance -ClassName Win32_ComputerSystem).UserName).Split("\")[1]
$Credential = Get-Credential -UserName "umhs\umhs-$User" -Message "Enter Secondary Credentials"
$Computers = Read-Host "Enter comma delimited list of computer names"

foreach ($Computer in $Computers.Split(",").Trim()){
    if (Test-Connection -ComputerName $Computer -Count 1 -Quiet){
        try {
            $Session = New-CimSession -Credential $Credential -ComputerName $Computer
            $Win32_OperatingSystem = Get-CimInstance -CimSession $Session -ClassName Win32_OperatingSystem

            $deviceInfo = [PSCustomObject]@{
                'Computer' = $Computer
                'OS Name' = $Win32_OperatingSystem.Caption
                'OS Version' = $WinVersionMap[$Win32_OperatingSystem.BuildNumber]
            }

            $deviceInfoList += $deviceInfo
        }
        catch {
            Write-Error "Failed to retrieve OS Information from $Computer. Error: $_"
        }
    }
    else {
        Write-Error "$Computer is unreachable"
    }
}
Read-Host "Press any key to exit"
