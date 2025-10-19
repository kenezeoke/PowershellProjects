param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Create", "Update")]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$InstanceUrl,

    [string]$IncidentNumber,    # Required for Update
    [string]$ShortDescription,
    [string]$Description,
    [string]$State               # e.g., 1=New, 2=In Progress, 3=On Hold
)

# --- Load credentials ---
$credPath = "$env:USERPROFILE\servicenow_cred.xml"
if (-not (Test-Path $credPath)) {
    Write-Host "Credential file not found at $credPath"
    exit 1
}

$cred = Import-Clixml -Path $credPath
$username = $cred.UserName
$password = $cred.GetNetworkCredential().Password
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($username):$password"))
$headers = @{ Authorization = "Basic $base64Auth"; "Content-Type" = "application/json" }

# --- Logging function ---
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "$timestamp - $Message"
    Write-Host $logLine
    Add-Content -Path "$PSScriptRoot\SNOW_Automation.log" -Value $logLine
}

# --- API base URL ---
$apiUrl = "$InstanceUrl/api/now/table/incident"

switch ($Action) {

    "Create" {
        if (-not $ShortDescription) {
            Write-Host "ShortDescription is required to create an incident."
            exit 1
        }

        $body = @{
            short_description = $ShortDescription
            description       = $Description
            state             = $State
        } | ConvertTo-Json

        Write-Log "Creating incident: $ShortDescription"
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body
        Write-Log "Incident created: Number $($response.result.number), Sys ID $($response.result.sys_id)"
    }

    "Update" {
        if (-not $IncidentNumber) {
            Write-Host "IncidentNumber is required for update."
            exit 1
        }

        # Find the sys_id of the incident
        $queryUrl = "$apiUrl?sysparm_query=number=$IncidentNumber&sysparm_fields=sys_id,number"
        $incident = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $headers

        if ($incident.result.Count -eq 0) {
            Write-Host "Incident $IncidentNumber not found."
            exit 1
        }

        $sysId = $incident.result[0].sys_id
        $body = @{
            short_description = $ShortDescription
            description       = $Description
            state             = $State
        } | ConvertTo-Json

        Write-Log "Updating incident $IncidentNumber (Sys ID $sysId)"
        $updateUrl = "$apiUrl/$sysId"
        $response = Invoke-RestMethod -Uri $updateUrl -Method Patch -Headers $headers -Body $body
        Write-Log "Incident updated: Number $($response.result.number), Sys ID $($response.result.sys_id)"
    }

    default {
        Write-Host "Invalid action. Use Create or Update."
    }
}
