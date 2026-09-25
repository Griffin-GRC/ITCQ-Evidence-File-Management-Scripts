# These scripts are for pulling out individual files from organized 
# audit folders provided by auditees.

# In your evidence folder, type and enter "powershell" in the search 
# bar. This places PowerShell into your audit evidence folder.

# Run this script below to get a preview of how your files will be 
# pulled out. It does not move anything. It just shows every file 
# that would be affected.

Get-ChildItem -Directory | Get-ChildItem -File -Recurse | Select-Object FullName

# If the preview looks correct, run the script below to pull out 
# files from folders. It intentionally excludes and reports any 
# collisions with any files with duplicate names.

$Parent = Get-Location

Get-ChildItem -Directory |
    Get-ChildItem -File -Recurse |
    ForEach-Object {
        $Destination = Join-Path $Parent $_.Name

        if (Test-Path -LiteralPath $Destination) {
            Write-Warning "NOT MOVED - duplicate filename: $($_.FullName)" # avoids files with duplicate names.
        }
        else {
            Move-Item -LiteralPath $_.FullName -Destination $Parent
            Write-Host "Moved: $($_.Name)"
        }
    }