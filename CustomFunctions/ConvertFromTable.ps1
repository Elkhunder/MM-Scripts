 function ConvertFrom-FixedColumnTable {
   [CmdletBinding()]
   param(
     [Parameter(ValueFromPipeline)] [string] $InputObject
   )

   begin {
     Set-StrictMode -Version 1
     $lineNdx = 0
   }

   process {
     $lines =
       if ($InputObject.Contains("`n")) { $InputObject.TrimEnd("`r", "`n") -split '\r?\n' }
       else { $InputObject }
     foreach ($line in $lines) {
       ++$lineNdx
       if ($lineNdx -eq 1) {
         # header line
         $headerLine = $line
       }
       elseif ($lineNdx -eq 2) {
         # separator line
         # Get the indices where the fields start.
         $fieldStartIndices = [regex]::Matches($headerLine, '\b\S').Index
         # Calculate the field lengths.
         $fieldLengths = foreach ($i in 1..($fieldStartIndices.Count-1)) {
           $fieldStartIndices[$i] - $fieldStartIndices[$i - 1] - 1
         }
         # Get the column names
         $colNames = foreach ($i in 0..($fieldStartIndices.Count-1)) {
             $headerLine.Substring($fieldStartIndices[$i], $fieldLengths[$i]).Trim()
           }
         }
       else {
         # data line
         $oht = [ordered] @{} # ordered helper hashtable for object constructions.
         $i = 0
         foreach ($colName in $colNames) {
           $oht[$colName] =
             if ($fieldStartIndices[$i] -lt $line.Length) {
               if ($fieldLengths[$i] -and $fieldStartIndices[$i] + $fieldLengths[$i] -le $line.Length) {
                 $line.Substring($fieldStartIndices[$i], $fieldLengths[$i]).Trim()
               }
               else {
                 $line.Substring($fieldStartIndices[$i]).Trim()
               }
             }
           ++$i
         }
         # Convert the helper hashable to an object and output it.
         [pscustomobject] $oht
       }
     }
   }
 }
