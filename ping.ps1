$Scope = $args[0].Scope
$Computers = $args[0].Computers
$Scope
$Computers
# ForEach ($targetComputer in (Get-Content C:\Users\jsissom\Desktop\computerlist.txt)) {
#     if (Test-Connection -ComputerName $targetComputer -Count 1 -Quiet) {
#         "$targetComputer - Ping OK"
#     } else {
#         "$targetComputer - Ping FAIL"
#     }
# }

