$ProcessInfo = Get-Process | Select-Object CPU,Id,ProcessName | Sort-Object CPU -Descending | Select-Object -First 10
$DateInfo = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$FileInfo = Join-Path $PSScriptRoot "text.csv" 
$ProcessInfo | Export-Csv -Path $FileInfo -NoTypeInformation
Write-Host "Report generated on $DateInfo and saved to $FileInfo"

$InfoStorage = [PSCustomObject]@{
    TimeStamp = $DateInfo
    TopProcesses = $ProcessInfo
}

$InfoStorage | ConvertTo-Json | Out-File -FilePath (Join-Path $PSScriptRoot "SystemInfoReport.json")
$InfoStorage | ConvertTo-Html | Out-File -FilePath (Join-Path $PSScriptRoot "SystemInfoReport.html")