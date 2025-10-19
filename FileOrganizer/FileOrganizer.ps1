$fileArray = @("document1.txt", "document2.txt", "image1.png", "image2.jpg", "script.docx", "notes.docx")
$fileArray | ForEach-Object {
    Set-Content -Path (Join-Path $PSScriptRoot $_) -Value "Sample content for $_"
}

Write-Host "Sample files created in $PSScriptRoot"

    (Get-ChildItem -Path $PSScriptRoot).Name | ForEach-Object {
        $extension = [IO.Path]::GetExtension($_).ToLower()
        $fileName = $_
        switch ($extension) {
            ".txt" {
                $destination = Join-Path $PSScriptRoot "TextFiles"
                if (-not (Test-Path $destination)) {
                    New-Item -ItemType Directory -Path $destination 
                }
                Move-Item -Path (Join-Path $PSScriptRoot $fileName) -Destination $destination
            }
            ".png"  {
                $destination = Join-Path $PSScriptRoot "Images"
                if (-not (Test-Path $destination)) {
                    New-Item -ItemType Directory -Path $destination 
                }
                Move-Item -Path (Join-Path $PSScriptRoot $fileName) -Destination $destination
            }
            ".jpg"  {
                $destination = Join-Path $PSScriptRoot "Images"
                if (-not (Test-Path $destination)) {
                    New-Item -ItemType Directory -Path $destination | Out-Null
                }
                Move-Item -Path (Join-Path $PSScriptRoot $fileName) -Destination $destination
            }
            ".docx" {
                $destination = Join-Path $PSScriptRoot "Documents"
                if (-not (Test-Path $destination)) {
                    New-Item -ItemType Directory -Path $destination | Out-Null
                }
                Move-Item -Path (Join-Path $PSScriptRoot $fileName) -Destination $destination
            }
            Default {
                Write-Host "No specific folder for file type: $extension. Leaving file in place."
            }
        }
    }


