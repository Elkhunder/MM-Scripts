$Computer = Read-Host "Please Enter Computer Name: "
Get-WmiObject -Class Win32_UserProfile -Computer $computer | Where-Object {$_.Special -ne 'Special'} | Select-Object LocalPath, Loaded
