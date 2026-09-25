# ITCQ Evidence File Management Scripts

A small collection of PowerShell utilities for organizing and renaming
IT Control Questionnaire (ITCQ) evidence files.

The scripts are intended to simplify repetitive evidence-management
tasks while preserving the original descriptive filenames.

## Features

-   Preview files contained in multiple evidence subfolders.
-   Flatten a folder structure by moving files from subfolders into the
    parent evidence folder.
-   Detect duplicate filenames before moving files.
-   Add sequential evidence identifiers to filenames.
-   Start the identifier sequence at `A1.27b`, intentionally leaving
    `A1.27a` unused.
-   Continue alphabetically beyond `z` using an Excel-style sequence:
    `aa`, `ab`, `ac`, ..., `aaa`, etc.
-   Preserve each file's original descriptive name and extension.

## Requirements

-   Windows
-   PowerShell 5.1 or later
-   Appropriate read/write permissions for the evidence directory

No external PowerShell modules are required.

## Recommended Workflow

### 1. Open PowerShell in the Evidence Folder

In Windows File Explorer, navigate to the parent evidence folder. Click
the address bar, type:

``` text
powershell
```

and press **Enter**.

This opens PowerShell with the current directory set to the evidence
folder.

### 2. Preview Files in Subfolders

Before moving anything, preview the files that will be affected:

``` powershell
Get-ChildItem -Directory | Get-ChildItem -File -Recurse | Select-Object FullName
```

This command is read-only and does not modify any files.

### 3. Flatten the Evidence Folder Structure

The following script moves files from all subfolders into the current
parent directory:

``` powershell
$Parent = Get-Location

Get-ChildItem -Directory |
    Get-ChildItem -File -Recurse |
    Move-Item -Destination $Parent
```

The source folders remain in place after their files are moved.

### 4. Safer Flattening with Duplicate Detection

For evidence handling, the following version is preferred because it
does not intentionally overwrite an existing file when the same filename
is encountered:

``` powershell
$Parent = Get-Location

Get-ChildItem -Directory |
    Get-ChildItem -File -Recurse |
    ForEach-Object {
        $Destination = Join-Path $Parent $_.Name

        if (Test-Path -LiteralPath $Destination) {
            Write-Warning "NOT MOVED - duplicate filename: $($_.FullName)"
        }
        else {
            Move-Item -LiteralPath $_.FullName -Destination $Parent
            Write-Host "Moved: $($_.Name)"
        }
    }
```

Review any duplicate warnings manually before taking further action.

## Sequential Evidence Renaming

The renaming convention used by this project is:

``` text
A1.27b - Original Filename.ext
A1.27c - Original Filename.ext
A1.27d - Original Filename.ext
...
A1.27z - Original Filename.ext
A1.27aa - Original Filename.ext
A1.27ab - Original Filename.ext
```

`A1.27a` is intentionally skipped.

Files are processed in ascending order by their existing filename.

### Preview Renaming

Always preview the proposed names before performing the rename:

``` powershell
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
$counter = 2   # 1=a; starting at 2 intentionally begins with b

foreach ($file in $files) {
    $letter = Get-LetterCode $counter
    $newName = "A1.27$letter - $($file.Name)"

    Write-Host "$($file.Name)"
    Write-Host "  -> $newName"

    $counter++
}
```

The preview does not rename or otherwise modify the files.

### Perform the Rename

After verifying the preview:

``` powershell
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
    $newName = "A1.27$letter - $($file.Name)"

    Rename-Item -LiteralPath $file.FullName -NewName $newName
    Write-Host "Renamed: $newName"

    $counter++
}
```

The alphabetic identifier can continue well beyond `z`. For example:

``` text
b ... z
aa ... az
ba ... zz
aaa ... zzz
aaaa ...
```

This allows the same approach to accommodate hundreds or thousands of
files.

## Example

Before:

``` text
ITCQ Evidence/
├── Q1/
│   ├── ITCQ Q1 - ETSU Relevant Policies.docx
│   └── ITCQ Q1 - WISP 2026c.docx
├── Q3/
│   └── ITCQ Q3 - ITS Organization Chart.pdf
└── Q4/
    └── ITCQ Q4 Evidence Collection.pdf
```

After flattening and renaming:

``` text
ITCQ Evidence/
├── A1.27b - ITCQ Q1 - ETSU Relevant Policies.docx
├── A1.27c - ITCQ Q1 - WISP 2026c.docx
├── A1.27d - ITCQ Q3 - ITS Organization Chart.pdf
└── A1.27e - ITCQ Q4 Evidence Collection.pdf
```

## Data Protection and Audit Considerations

These scripts modify filesystem locations and filenames. Before using
them on authoritative evidence:

-   Retain an appropriate backup or authoritative source copy.
-   Run preview commands before commands that modify files.
-   Confirm the current PowerShell working directory with
    `Get-Location`.
-   Review duplicate-filename warnings before proceeding.
-   Verify file counts before and after moving evidence.
-   Consider retaining a file inventory or cryptographic hashes when
    chain of custody or evidence integrity requirements warrant it.
-   Do not commit confidential, restricted, sensitive, or otherwise
    non-public audit evidence to a source-code repository unless the
    repository and handling process are specifically authorized for that
    information.

The scripts do not alter the contents of the evidence files, but moving
and renaming files changes filesystem metadata and paths.

## Suggested Repository Structure

``` text
project/
├── .gitignore
├── README.md
├── scripts/
│   ├── Flatten-EvidenceFolders.ps1
│   └── Rename-EvidenceFiles.ps1
├── evidence/       # ignored by Git
├── output/         # ignored by Git
└── temp/           # ignored by Git
```

Keeping scripts separate from evidence reduces the risk of accidentally
committing evidence to the repository.

## `.gitignore`

At minimum, consider excluding working evidence and generated-output
directories:

``` gitignore
/evidence/
/output/
/temp/
/backup/
/backups/

*.log
*.tmp
*.bak

PowerShell_transcript.*

Thumbs.db
Desktop.ini
$RECYCLE.BIN/

.vscode/
.vs/
.idea/

.DS_Store

.env
.env.*
*.key
*.pem
*.pfx
*.p12
credentials.*
secrets.*
```

If the repository will never contain legitimate sample documents, you
may also choose to ignore common evidence formats such as PDF, Word,
Excel, PowerPoint, image, and archive files. Directory-based exclusions
are generally more flexible when sample/test files need to be version
controlled.

> **Important:** `.gitignore` does not stop Git from tracking a file
> that has already been committed. Previously tracked sensitive files
> require separate removal from the Git index and, where necessary,
> repository history.

## Disclaimer

Test these scripts on non-production copies before using them on
authoritative evidence. Review the commands and adapt paths, naming
conventions, and safeguards to the requirements of the specific
engagement or environment.

## License

No license is specified by this README. Add a `LICENSE` file if you
intend to define terms for reuse, modification, or distribution.
