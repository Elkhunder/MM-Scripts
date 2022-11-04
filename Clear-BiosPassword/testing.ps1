Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName SecurityInterface
Get-CimClass -Namespace root/dcim/sysman/wmisecurity -ClassName SecurityInterface
Set-CimInstance -Namespace

$pawd = "yous2323"
$encoder = New-Object System.Text.UTF8Encoding
$bytes = $encoder.GetBytes($pawd)
[Uint32]$SecType = 1
[UInt32]$SecHndCount = $bytes.Length
[string]$NameId = 'Admin'
[string]$NewPassword = ''
[string]$OldPassword = 'yous2323'

$Arguments = @{
  NameId = $NameId;
  NewPassword = $NewPassword;
  OldPassword = $OldPassword;
  SecHandle = $bytes;
  SecHndCount = $SecHndCount;
  SecType = $SecType
}

Invoke-CimMethod -NameSpace root/dcim/sysman/wmisecurity -ClassName SecurityInterface -MethodName SetNewPassword -Arguments $Arguments

function Get-IsDellBiosPasswordSet{
  $BiosPassword = Get-CimInstance -CimSession $CimSession -Namespace root\dcim\sysman\wmisecurity -ClassName PasswordObject |
  Where-Object NameId -EQ "Admin" |
  Select-Object -ExpandProperty IsPasswordSet

  if($BiosPassword){
    Write-Host "Bios Password is set"
  }
  if(!$BiosPassword){
    Write-Host "Bios Password has already been cleared ..."
  }
}

$credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
$credentials

$BiosPassword = ((Get-StoredCredential) | Where-Object UserName -eq 'jsissom').Password
$BiosPassword
[System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($BiosPassword))