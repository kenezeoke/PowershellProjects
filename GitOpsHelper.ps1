<#
.SYNOPSIS
GitOps Helper Script to automate Git workflows using GitUtils module
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Init", "CommitPush", "NewBranch")]
    [string]$Action,

    [string]$RepoPath = (Get-Location),

    [string]$BranchName,

    [string]$CommitMessage
)

# --- Import GitUtils module ---
$modulePath = Join-Path $PSScriptRoot "Helper.psm1"
if (-not (Test-Path $modulePath)) {
    Write-Host "Module not found at $modulePath"
    exit 1
}
Import-Module $modulePath -Force

# --- Switch Based on Action ---
switch ($Action) {

    "Init" {
        if (Test-GitRepo -Path $RepoPath) {
            Write-Host "Git repository already exists at $RepoPath"
        } else {
            Write-Host "Initializing Git repository at $RepoPath..."
            git init $RepoPath
            Write-Host "Repository initialized."
        }
    }

    "CommitPush" {
        if (-not (Test-GitRepo -Path $RepoPath)) {
            Write-Host "Error: No Git repository found at $RepoPath. Initialize first."
            exit 1
        }

        if (-not $CommitMessage) {
            Write-Host "Error: Commit message is required for CommitPush action."
            exit 1
        }

        Write-Host "Adding all changes..."
        git -C $RepoPath add .

        Write-Host "Committing changes..."
        git -C $RepoPath commit -m "$CommitMessage"

        Write-Host "Pushing changes to origin..."
        git -C $RepoPath push

        Write-Host "Changes pushed successfully."
    }

    "NewBranch" {
        if (-not (Test-GitRepo -Path $RepoPath)) {
            Write-Host "Error: No Git repository found at $RepoPath. Initialize first."
            exit 1
        }

        if (-not $BranchName) {
            Write-Host "Error: Branch name is required for NewBranch action."
            exit 1
        }

        Write-Host "Creating new branch '$BranchName'..."
        git -C $RepoPath checkout -b $BranchName

        Write-Host "Branch '$BranchName' created and switched to."
    }

    default {
        Write-Host "Invalid action. Use Init, CommitPush, or NewBranch."
    }
}
