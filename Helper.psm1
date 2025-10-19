# --- Helper Function: Validate Repo ---
function Test-GitRepo {
    <#
    .SYNOPSIS
    Checks if a directory contains a Git repository
    .PARAMETER Path
    The path to check for a Git repository
    #>
    param([Parameter(Mandatory=$true)][string]$Path)
    return Test-Path (Join-Path $Path ".git")
}

# Export the function so it is available when the module is imported
Export-ModuleMember -Function Test-GitRepo
