# Color output
function Write-Color($Text, $Color="White") {
    Write-Host $Text -ForegroundColor $Color
}

# 1. Start and run
Write-Color "Hi! Would you run the script?" 'Cyan'
$startResponse = Read-Host "Proceed? (Y/N)"
if ($startResponse.ToLower() -ne 'y') {
    Write-Color "Press any key to exit..." 'Yellow'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit
}

# 2. Enter download folder
$downloadPath = Read-Host "Enter download path (e.g., C:\Downloads)"
if (!(Test-Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath | Out-Null
    Write-Color "Folder created: $downloadPath" 'Green'
} else {
    Write-Color "Folder already exists: $downloadPath" 'Green'
}

# 3. Enter download source
$linkSource = Read-Host "Enter source links.txt URL or path"
$tempLinksFile = "$env:TEMP\links.txt"

if ($linkSource -match '^(http|https)://') {
    try {
        Invoke-WebRequest -Uri $linkSource -OutFile $tempLinksFile -UseBasicParsing
        Write-Color "Links successfully downloaded." 'Green'
    } catch {
        Write-Color "Error downloading links." 'Red'
        exit
    }
} elseif (Test-Path $linkSource) {
    Copy-Item $linkSource $tempLinksFile -Force
    Write-Color "Links file copied." 'Green'
} else {
    Write-Color "File not found. Please check URL or path." 'Red'
    exit
}

# 4. Path to 7-Zip
$zipPath = Read-Host "Enter path to 7z.exe (e.g., C:\Program Files\7-Zip\7z.exe)"
if (!(Test-Path $zipPath)) {
    Write-Color "7-Zip executable not found." 'Red'
    exit
}

# 5. Links processing
$links = Get-Content $tempLinksFile | Where-Object { $_ -match '^https?://' }
$totalLinks = $links.Count
$logFile = "$downloadPath\download_log.txt"

# Clear log
"" | Out-File $logFile

$processedCount = 0

foreach ($link in $links) {
    $processedCount++
    $fileName = Split-Path -Path $link -Leaf
    if ([string]::IsNullOrEmpty($fileName)) {
        $fileName = "file" + $processedCount + ".download"
    }

    $destinationFile = Join-Path $downloadPath $fileName

    # Progress
    $percent = [math]::Round(($processedCount / $totalLinks) * 100, 2)
    Write-Color "Processing $processedCount of $totalLinks ($percent%) : $link" 'Cyan'

    # Download the file
    try {
        Invoke-WebRequest -Uri $link -OutFile "$destinationFile.tmp" -UseBasicParsing -ErrorAction Stop
        Move-Item "$destinationFile.tmp" $destinationFile -Force
        Write-Color "Downloaded: $fileName" 'Green'
        Add-Content $logFile "SUCCESS: $link"
    } catch {
        Write-Color "Download error: $link" 'Red'
        Add-Content $logFile "FAIL: $link"
        continue
    }

    # Extract
    $ext = [IO.Path]::GetExtension($fileName).ToLower()
    if ($ext -in @('.zip','.7z','.rar')) {
        Write-Color "Extracting: $fileName" 'Yellow'
        $archiveBaseName = [IO.Path]::GetFileNameWithoutExtension($fileName)

        # Safe folder name creating
        $safeFolderName = ($archiveBaseName -replace '[\\/:*?"<>|]', '_')
        $extractFolderPath = Join-Path $downloadPath $safeFolderName

        # Create or clear folder
        if (Test-Path $extractFolderPath) {
            Remove-Item "$extractFolderPath\*" -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            New-Item -ItemType Directory -Path $extractFolderPath | Out-Null
        }

        # Extracting
    try {
        # arguments without ""
        $args = @(
            "x"          # extracting
            "-y"         # auto approve
            "$destinationFile"             # destination file
            "-o$extractFolderPath"          # destinantion folder
        )

        # Run
        $result = & "$zipPath" @args 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Color "Extraction successful: $fileName to folder: $safeFolderName" 'Green'
            Add-Content $logFile "EXTRACTED: $fileName to folder: $safeFolderName"
        } else {
            Write-Color "Extraction error: $fileName" 'Red'
            Write-Color "7z output: $result" 'Red'
        }
    } catch {
        Write-Color "Exception during extraction: $_" 'Red'
    }
    }

    # File size
    if (Test-Path $destinationFile) {
        $fileSizeMB = [math]::Round((Get-Item $destinationFile).Length / 1MB, 2)
        Write-Color "File size: $fileSizeMB MB" 'Magenta'
    }

    Write-Host "" # empty string 
}

# Result
Write-Color "Process completed." 'Cyan'
Write-Color "Total links: $totalLinks" 'Yellow'
try {
    $successCount = (Select-String -Path $logFile -Pattern '^SUCCESS').Count
} catch {
    $successCount = 0
}
Write-Color "Successfully downloaded: $successCount" 'Green'
Write-Color "Log file: $logFile" 'Gray'
Write-Color "Download folder: $downloadPath" 'Gray'
Write-Color "Press any key to exit..." 'Yellow'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
