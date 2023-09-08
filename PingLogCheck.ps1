$logfile = "C:\temp\pinglog.txt"  # destination file for logging
$IPaddress = "192.168.1.1"  # IP address to ping
$logType = "Both"  # Change to "Failure" for logging failures, "Success" for logging successes only, and "Both" for logging both.

# loop indefinitely
while($true) {
  $ping = Test-Connection -ComputerName $IPaddress -Count 1 -Quiet

  # Create the log message
  if($ping) {
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $IPaddress is reachable"
  } else {
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $IPaddress is unreachable"
  }
  
  if($ping -and ($mode -eq "Success" -or $mode -eq "Both")) {
    # write current date/time and IP to logfile with a success message
    $logMessage | Out-File -Append -FilePath $logfile
  } 
  elseif(-not $ping -and (($mode -eq "Failure") -or $mode -eq "Both")) {
    # write current date/time and IP to logfile with a failure message
    $logMessage | Out-File -Append -FilePath $logfile
  }
  Write-Output $logMessage
  Start-Sleep -Seconds 1800  # wait 1800 seconds (30 minutes) before next ping
}
