$filename = Read-Host -Prompt "Input filename w/ extension"
$computers = Get-Content "C:\Users\$env:USERNAME\Desktop\$filename"
$output = foreach ($computer in $computers) {
  try {
    $reachable = Test-Connection -Cn $computer -BufferSize 16 -Count 1 -ea 0 -quiet
    $output = @()
    ### Check to see if computer is reachable
    if ($reachable)
    {
        ### Get printer list
        Write-Host `Pulling information from $computer ...`
        $printerList = Get-Printer -ComputerName $computer -Name "LOCAL"| Select-Object Name
        $details = "information pulled from $computer successfully" 
    }
    else
    {
        $details = `-$computer is not online, no information was gathered`
    }

    ### Store the information in an array
    New-Object -TypeName PSObject -Property @{
        TermID = $computer
        Online = $reachable
        Printer = $printerlist
        Details = $details
    } | Select-Object TermID, Online, Printer, Details


    }catch{
        Write-Host 'An error occured'
        Write-Host $_
        }
}
$output | Export-Csv "C:\Users\$env:USERNAME\Desktop\getPrinters-Results.csv"
Read-Host -Prompt "Script has finished, please check output files"