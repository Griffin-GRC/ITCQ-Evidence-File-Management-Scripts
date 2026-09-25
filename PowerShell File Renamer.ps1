# These scripts are for renaming audit evidence files in 
# accordance with COT TeamMate+ naming conventions.

# Each script starts at A1.27b, proceeds through A1.27z, and then 
# continues A1.27aa, A1.27ab, A1.27ac, etc. Change as needed.

# In your evidence folder with INDIVIDUAL files (this doesn't 
# affect folders), type and enter "powershell" in the search bar. 
# This places PowerShell into your audit evidence folder.

# Run this script below to get a preview of how your files will be renamed. 
function Get-LetterCode {
    param([int]$Number)

    $result = ""
    while ($Number -gt 0) {
        $Number--
        $result = [char](97 + ($Number % 26)) + $result
        $Number = [math]::Floor($Number / 26)
    }
    return $result
}

$files = Get-ChildItem -File | Sort-Object Name
$counter = 2   # 1=a, so 2 starts at b

foreach ($file in $files) {
    $letter = Get-LetterCode $counter
    $newName = "A1.27$letter - $($file.Name)" # change this in accordance with your specific audit step or naming convention.

    Write-Host "$($file.Name)"
    Write-Host "  -> $newName"

    $counter++
}

# If the preview looks correct, run the script below. 
function Get-LetterCode {
    param([int]$Number)

    $result = ""
    while ($Number -gt 0) {
        $Number--
        $result = [char](97 + ($Number % 26)) + $result
        $Number = [math]::Floor($Number / 26)
    }
    return $result
}

$files = Get-ChildItem -File | Sort-Object Name
$counter = 2   # Start at b

foreach ($file in $files) {
    $letter = Get-LetterCode $counter
    $newName = "A1.27$letter - $($file.Name)" # change this in accordance with your specific audit step or naming convention.

    Rename-Item -LiteralPath $file.FullName -NewName $newName
    Write-Host "Renamed: $newName"

    $counter++
}