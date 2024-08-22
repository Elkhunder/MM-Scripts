# function Watch-DeviceStatus {
#     [CmdletBinding()]
#     param (
#         # Mandatory if not using PromptForFile
#         [Parameter(Mandatory = $true, ParameterSetName = 'ByComputerName')]
#         [string[]]$ComputerName,

#         # Optional switch to prompt for a file instead of providing computer names directly
#         [Parameter(Mandatory = $true, ParameterSetName = 'ByFile')]
#         [switch]$UseInFile,

#         # Interval and Timeout parameters apply to both parameter sets
#         [Parameter(Mandatory = $false)]
#         [int]$IntervalSeconds = 30,

#         [Parameter(Mandatory = $false)]
#         [int]$TimeoutMinutes = 60

#     )

#     # Begin block runs once before the process block
#     begin {
#         $jobs = @()
#     }

#     # Process block runs for each object passed to the function
#     process {
#         foreach ($name in $ComputerName) {
#             $job = Start-Job -Name "Monitor_$name" -ScriptBlock {
#                 param ($name, $interval, $timeout, $verbose)

#                 $timeoutTime = [datetime]::Now.AddMinutes($timeout)
#                 $isOnline = $false

#                 if ($verbose) {
#                     Write-Verbose "Monitoring $name. Timeout set to $timeout minutes."
#                 }

#                 while (-not $isOnline -and [datetime]::Now -lt $timeoutTime) {
#                     try {
#                         $pingResult = Test-Connection -ComputerName $name -Count 1 -Quiet
#                         if ($name -eq 'localhost'){
#                             # For testing purposes
#                             Start-Sleep -Seconds 60
#                         } else {
#                             # For testing purposes
#                             Start-Sleep -Seconds $(60*2)
#                         }
#                         if ($pingResult) {
#                             $isOnline = $true
#                             $message = "[$(Get-Date)] $name is now online!"

#                             # Output the message to the console
#                             Write-Output $message

#                             # Send a notification (using BurntToast for Windows)
#                             if ($env:OS -match "Windows") {
#                                 Import-Module BurntToast -ErrorAction SilentlyContinue
#                                 New-BurntToastNotification -Text "Computer Online", $message
#                             } else {
#                                 Write-Output "Notification: $message"
#                             }
#                         } else {
#                             if ($verbose) {
#                                 Write-Verbose "[$(Get-Date)] $name is still offline."
#                             }
#                             Start-Sleep -Seconds $interval
#                         }
#                     } catch {
#                         Write-Warning "An error occurred while checking ${name}: $_"
#                     }
#                 }

#                 if (-not $isOnline) {
#                     Write-Output "[$(Get-Date)] Timeout reached. $name did not come online within the allotted time."
#                 }

#             } -ArgumentList $name, $IntervalSeconds, $TimeoutMinutes, $VerboseOutput

#             $jobs += $job
#         }
#     }

#     # End block runs once after all process blocks have run
#     end {
#         if ($jobs.Count -gt 0) {
#             Write-Output "Monitoring started for $($jobs.Count) computer(s). Use 'Get-Job' to see the status of the jobs."
#             Write-Output "Use 'Receive-Job' to see the results and 'Remove-Job' to clean up completed jobs."
#         }
#     }
# }


function Watch-DeviceStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ByComputerName')]
        [string[]]$ComputerName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByFile')]
        [switch]$UseInFile,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Default',
                     'IM',
                     'Mail',
                     'Reminder',
                     'SMS',
                     'Alarm',
                     'Alarm2',
                     'Alarm3',
                     'Alarm4',
                     'Alarm5',
                     'Alarm6',
                     'Alarm7',
                     'Alarm8',
                     'Alarm9',
                     'Alarm10',
                     'Call',
                     'Call2',
                     'Call3',
                     'Call4',
                     'Call5',
                     'Call6',
                     'Call7',
                     'Call8',
                     'Call9',
                     'Call10')]
        [String] $Sound = 'Default', 

        [Parameter(Mandatory = $false)]
        [int]$IntervalSeconds = 30,

        [Parameter(Mandatory = $false)]
        [int]$TimeoutMinutes = 60
    )

    begin {
        $jobs = @()
    }

    process {
        foreach ($name in $ComputerName) {
            $job = Start-Job -Name "Monitor_$name" -ScriptBlock {
                param ($name, $interval, $timeout, $verbosePreference)
                $VerbosePreference = $verbosePreference
                $timeoutTime = [datetime]::Now.AddMinutes($timeout)
                $isOnline = $false

                if ($verbose) {
                    Write-Verbose "Monitoring $name. Timeout set to $timeout minutes."
                }

                while (-not $isOnline -and [datetime]::Now -lt $timeoutTime) {
                    try {
                        $pingResult = Test-Connection -ComputerName $name -Count 1 -Quiet
                        # if ($name -eq 'localhost'){
                        #     Start-Sleep -Seconds 60
                        # } else {
                        #     Start-Sleep -Seconds $(60*2)
                        # }
                        if ($pingResult) {
                            $isOnline = $true
                            $message = "[$(Get-Date)] $name is now online!"

                            Write-Output $message
                            Write-Verbose "Verbose: ${Verbose}"
                            $currentVerbosePreference = $VerbosePreference
                            $verbosePreference = 'SilentlyContinue'
                            if ($env:OS -match "Windows") {
                                Import-Module BurntToast -ErrorAction SilentlyContinue
                                New-BurntToastNotification -Text "Device is Online!", $message
                            } else {
                                Write-Output "Notification: $message"
                            }
                            $VerbosePreference = $currentVerbosePreference
                        } else {
                            if ($Verbose) {
                                Write-Verbose "[$(Get-Date)] $name is still offline."
                            }
                            Start-Sleep -Seconds $interval
                        }
                    } catch {
                        Write-Warning "An error occurred while checking ${name}: $_"
                    }
                }

                if (-not $isOnline) {
                    Write-Output "[$(Get-Date)] Timeout reached. $name did not come online within the allotted time."
                }
            } -ArgumentList $name, $IntervalSeconds, $TimeoutMinutes, $VerbosePreference

            $jobs += $job
        }
    }

    end {
        if ($jobs.Count -gt 0) {
            Write-Output "Monitoring started for $($jobs.Count) computer(s). Use 'Get-Job' to see the status of the jobs."
            Write-Output "Use 'Receive-Job' to see the results and 'Remove-Job' to clean up completed jobs."
        }

        while ($jobs | Where-Object { $_.State -ne 'Completed' }) {
            foreach ($job in $jobs) {

                if ($job.State -eq 'Completed'){
                    Receive-Job -Job $job | Write-Output
                    Remove-Job -Job $job
                    $jobs = $jobs | Where-Object {
                        $_.Id -ne $job.Id
                    }
                }
                else{
                    Receive-Job -Job $job -Keep | Write-Output
                }
            }
            Start-Sleep -Seconds 5
        }
        Get-Job -Name "Monitor_*" | ForEach-Object {
            Remove-Job -Job $_
        }
    }
}