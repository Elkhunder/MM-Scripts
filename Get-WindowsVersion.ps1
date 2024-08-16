$User = ((Get-CimInstance -ClassName Win32_ComputerSystem).UserName).Split("\")[1]
$Credential = Get-Credential -UserName "umhs\umhs-$User" -Message "Enter Secondary Credentials"
$Computers = Read-Host "Enter comma delimited list of computer names"

foreach ($Computer in $Computers.Split(",").Trim()){
    if (Test-Connection -ComputerName $Computer -Count 1 -Quiet){
        $Session = New-CimSession -Credential $Credential -ComputerName $Computer
        $WindowsVersion = (Get-CimInstance -CimSession $Session -ClassName Win32_OperatingSystem).Caption
        Write-Host "$Computer : $WindowsVersion"
    }
    else {
        Write-Host "$Computer : Offline"
    }
}
Read-Host "Press any key to exit"
