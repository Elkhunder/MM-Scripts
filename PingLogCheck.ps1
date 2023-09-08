$logfile = "C:\temp\pinglog.txt"  # destination file for logging
$IPaddress = "192.168.1.1"  # IP address to ping
$logType = "Both"  # Change to "Failure" for logging failures, "Success" for logging successes only, and "Both" for logging both.

# loop indefinitely
while($true) {
  $ping = Test-Connection -ComputerName $IPaddress -Count 1 -Quiet
  
  if($ping -and ($logType -eq "Success" -or $logType -eq "Both")) {
    # write current date/time and IP to logfile with a success message
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $IPaddress is reachable" | Out-File -Append -FilePath $logfile
  } 
  elseif(-not $ping -and ($logType -eq "Failure" -or $logType -eq "Both")) {
    # write current date/time and IP to logfile with a failure message
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $IPaddress is unreachable" | Out-File -Append -FilePath $logfile
  }
  Start-Sleep -Seconds 1800  # wait 1800 seconds (30 minutes) before next ping
}
