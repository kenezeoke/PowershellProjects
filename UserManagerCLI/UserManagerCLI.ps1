param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Add-User", "Remove-User", "Get-Users")]
    [string]$Command,

    [string]$Username,
    [SecureString]$Password,
    [string]$Email
)

# Define user data file
$dataFile = Join-Path $PSScriptRoot "users.json"

# Ensure file exists
if (-not (Test-Path $dataFile)) {
    @() | ConvertTo-Json | Set-Content -Path $dataFile
}

# Load users if file has data
$users = @()
if ((Get-Content $dataFile -Raw).Trim().Length -gt 0) {
    $users = @(Get-Content $dataFile -Raw | ConvertFrom-Json)
}

switch ($Command) {

    "Add-User" {
        if (-not $Username -or -not $Email) {
            Write-Host "⚠️  Username and email are required to add a user."
            exit 1
        }

        # If no secure password was passed, prompt user securely
        if (-not $Password) {
            $Password = Read-Host "Enter password" -AsSecureString
        }

        if ($null -eq $Password) {
            Write-Host "❌ Password cannot be empty."
            exit 1
        }

        # Check if user already exists
        if ($users | Where-Object { $_.Username -eq $Username }) {
            Write-Host "⚠️  User '$Username' already exists."
        } 
        else {
            # Encrypt password
            $encryptedPassword = ConvertFrom-SecureString $Password

            # Create new user
            $newUser = [PSCustomObject]@{
                Username = $Username
                Password = $encryptedPassword
                Email    = $Email
            }

            # Add to list
            $users = @($users) + $newUser

            # Save to JSON
            $users | ConvertTo-Json | Set-Content -Path $dataFile
            Write-Host "✅ User '$Username' added successfully."
        }
    }

    "Remove-User" {
        if (-not $Username) {
            Write-Host "⚠️ Username is required to remove a user."
            exit 1
        }

        $userToRemove = $users | Where-Object { $_.Username -eq $Username }

        if ($userToRemove) {
            $users = $users | Where-Object { $_.Username -ne $Username }
            $users | ConvertTo-Json | Set-Content -Path $dataFile
            Write-Host "🗑️  User '$Username' removed successfully."
        } 
        else {
            Write-Host "⚠️  User '$Username' not found."
        }
    }

    "Get-Users" {
        if ($users.Count -eq 0) {
            Write-Host "No users found."
        } 
        else {
            Write-Host "`n📋 Registered Users:`n"
            $users | Format-Table Username, Email -AutoSize
        }
    }
}
