param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("TriggerBuild", "CheckStatus", "GetLogs")]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$Organization,

    [Parameter(Mandatory=$true)]
    [string]$Project,

    [Parameter(Mandatory=$true)]
    [int]$PipelineId,

    [string]$BuildId,       # Required for CheckStatus and GetLogs
    [Parameter(Mandatory=$true)]
    [string]$PAT
)

# --- Base64 encode the PAT for Authorization header ---
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PAT"))
$headers = @{ Authorization = "Basic $base64AuthInfo" }

$baseUrl = "https://dev.azure.com/$Organization/$Project/_apis/pipelines/$PipelineId"
$apiVersion = "7.1-preview.1"

switch ($Action) {

    "TriggerBuild" {
        Write-Host "Triggering pipeline $PipelineId..."
        $body = @{
            resources = @{
                repositories = @{
                    self = @{
                        refName = "refs/heads/main"
                    }
                }
            }
        } | ConvertTo-Json -Depth 10

        $response = Invoke-RestMethod -Uri "$baseUrl/runs?api-version=$apiVersion" `
                                      -Method Post `
                                      -Headers $headers `
                                      -Body $body `
                                      -ContentType "application/json"

        Write-Host "Pipeline triggered successfully. Run ID: $($response.id)"
    }

    "CheckStatus" {
        if (-not $BuildId) {
            Write-Host "BuildId is required for checking status."
            exit 1
        }

        Write-Host "Checking status for build ID $BuildId..."
        $response = Invoke-RestMethod -Uri "$baseUrl/runs/$BuildId?api-version=$apiVersion" `
                                      -Method Get `
                                      -Headers $headers

        Write-Host "Status: $($response.state)"
        Write-Host "Result: $($response.result)"
    }

    "GetLogs" {
        if (-not $BuildId) {
            Write-Host "BuildId is required for fetching logs."
            exit 1
        }

        Write-Host "Fetching logs for build ID $BuildId..."
        $logsUrl = "$baseUrl/runs/$BuildId/logs?api-version=$apiVersion"
        $logs = Invoke-RestMethod -Uri $logsUrl -Method Get -Headers $headers

        foreach ($log in $logs.value) {
            Write-Host "Log ID: $($log.id) - $($log.type)"
            Write-Host "URL: $($log.url)"
        }
    }

    default {
        Write-Host "Invalid action. Use TriggerBuild, CheckStatus, or GetLogs."
    }
}
