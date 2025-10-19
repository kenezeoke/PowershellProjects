function Invoke-Calculator {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("+", "-", "*", "/")]
        [string]$Operation,

        [Parameter(Mandatory = $true)]
        [int]$Num1,

        [Parameter(Mandatory = $true)]
        [int]$Num2
    )

    # Define the data file path
    $dataFile = Join-Path $PSScriptRoot "BasicCalculatorData.txt"

    # Ensure file exists
    if (-not (Test-Path $dataFile)) {
        Set-Content -Path $dataFile -Value "Basic Calculator Data File`n"
    }

    # Perform operation
    switch ($Operation) {
        "+" {
            $result = $Num1 + $Num2
        }
        "-" {
            $result = $Num1 - $Num2
        }
        "*" {
            $result = $Num1 * $Num2
        }
        "/" {
            if ($Num2 -eq 0) {
                Write-Host "❌ Error: Division by zero is not allowed."
                return
            } else {
                $result = [float]($Num1 / $Num2)
            }
        }
    }

    # Output result
    Write-Host "Result: $result"

    # Log operation to file
    $logEntry = "Last operation: $Num1 $Operation $Num2 = $result`n"
    Add-Content -Path $dataFile -Value $logEntry
}

# Example usage
 Invoke-Calculator -Operation "+" -Num1 10 -Num2 5
 Invoke-Calculator -Operation "/" -Num1 10 -Num2 0
