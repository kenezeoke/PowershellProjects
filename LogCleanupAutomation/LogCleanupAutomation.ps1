param(
   

    [Parameter(Mandatory = $true)]
    [int]$DaysOld,

    [string]$LogFile = "DeletedLogs.txt"
)

$LogDirectory = Join-Path $PSScriptRoot "Logs"
 
# Ensure the directory exists
if (-not (Test-Path $LogDirectory)) {
    Write-Host "❌ Log directory '$LogDirectory' does not exist." -ForegroundColor Red
    New-Item -Path $LogDirectory -ItemType Directory | Out-Null
    Write-Host "Created log directory at '$LogDirectory'."
    
}

# Prepare full path for the log file
$LogFilePath = Join-Path $LogDirectory $LogFile

# Add timestamp to log file
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $LogFilePath -Value "`n--- Cleanup started at $timestamp ---`n"

# Get files older than specified days
$cutoffDate = (Get-Date).AddDays(-$DaysOld)
$filesToDelete = Get-ChildItem -Path $LogDirectory -File | Where-Object { $_.LastWriteTime -lt $cutoffDate }

if ($filesToDelete.Count -eq 0) {
    Write-Host "No files older than $DaysOld days found in '$LogDirectory'."
    Add-Content -Path $LogFilePath -Value "No files deleted. Cleanup complete."
} else {
    foreach ($file in $filesToDelete) {
        try {
            # Delete the file
            Remove-Item -Path $file.FullName -Force -Verbose

            # Log deletion
            Write-Host "Deleted file: $($file.FullName)"
            Add-Content -Path $LogFilePath -Value "Deleted file: $($file.FullName)"
        }
        catch {
            Write-Host "❌ Failed to delete $($file.FullName): $_" -ForegroundColor Red
            Add-Content -Path $LogFilePath -Value "Failed to delete $($file.FullName): $_"
        }
    }

    Add-Content -Path $LogFilePath -Value "--- Cleanup finished at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---`n"
}
