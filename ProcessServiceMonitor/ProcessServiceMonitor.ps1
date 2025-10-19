param(
    [Parameter(Mandatory=$true)]
    [string[]]$Services,      # List of service names to monitor
    [int]$CpuThreshold = 80,   # CPU % threshold for alert
    [int]$MemoryThresholdMB = 1024, # Memory threshold in MB
    [string]$LogFile = "ServiceMonitorLog.txt"
)

# Prepare log file
$LogFilePath = Join-Path $PSScriptRoot $LogFile
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $LogFilePath -Value "`n--- Monitoring started at $timestamp ---`n"

foreach ($serviceName in $Services) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        $processId = (Get-WmiObject Win32_Service -Filter "Name='$serviceName'").ProcessId
        $process = Get-Process -Id $processId -ErrorAction SilentlyContinue

        # Check if service is running
        if ($service.Status -ne 'Running') {
            Write-Host "⚠️ Service '$serviceName' is stopped. Restarting..."
            Add-Content -Path $LogFilePath -Value "$($timestamp): Service '$serviceName' stopped. Restarting..."
            Start-Service -Name $serviceName
            Add-Content -Path $LogFilePath -Value "$($timestamp): Service '$serviceName' restarted."
            continue
        }

        # Monitor CPU and memory if process exists
        if ($process) {
            $cpu = $process | Measure-Object -Property CPU -Sum | Select-Object -ExpandProperty Sum
            $memMB = [math]::Round($process.WorkingSet / 1MB, 2)

            if ($cpu -gt $CpuThreshold) {
                Write-Host "⚠️ CPU usage high for '$serviceName': $cpu%"
                Add-Content -Path $LogFilePath -Value "$($timestamp): CPU usage high for '$serviceName': $($cpu)%"
            }

            if ($memMB -gt $MemoryThresholdMB) {
                Write-Host "⚠️ Memory usage high for '$serviceName': $memMB MB"
                Add-Content -Path $LogFilePath -Value "$($timestamp): Memory usage high for '$serviceName': $($memMB) MB"
            }
        } else {
            Write-Host "⚠️ Could not find process for service '$serviceName'."
            Add-Content -Path $LogFilePath -Value "$($timestamp): Could not find process for service '$serviceName'."
        }

    } catch {
        Write-Host "❌ Error monitoring service '$serviceName': $_"
        Add-Content -Path $LogFilePath -Value "$($timestamp): Error monitoring service '$serviceName': $_"
    }
}

Add-Content -Path $LogFilePath -Value "--- Monitoring finished at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---`n"
