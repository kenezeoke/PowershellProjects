param(
    [string]$ApiUrI = "https://jsonplaceholder.typicode.com/users",
    [string]$LogFile  = "logs/api.log"
)

if (-not (Test-Path $PSScriptRoot\logs)) {
    New-Item -Path $PSScriptRoot\logs -ItemType Directory | Out-Null
}

Write-Output "Fetching data from API: $ApiUrI"
$response = Invoke-RestMethod -Uri $ApiUrI -Method Get  -ErrorAction Stop

foreach( $user in $response ) {
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - User: $($user.name), Email: $($user.email)"
    Write-Output $logEntry
    Add-Content -Path (Join-Path $PSScriptRoot $LogFile) -Value $logEntry
}