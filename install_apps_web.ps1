# Функция для цветового вывода
function Write-Color($Text, $Color="White") {
    Write-Host $Text -ForegroundColor $Color
}

# 1. Приветствие и запуск
Write-Color "Hi! Run the script?" 'Cyan'
$startResponse = Read-Host "Proceed? (Y/N)"
if ($startResponse.ToLower() -ne 'y') {
    Write-Color "Press any key to exit..." 'Yellow'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit
}

# 2. Ввод папки для загрузки
$downloadPath = Read-Host "Enter download path (e.g., C:\Downloads)"
if (!(Test-Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath | Out-Null
    Write-Color "Folder created: $downloadPath" 'Green'
} else {
    Write-Color "Folder already exists: $downloadPath" 'Green'
}

# 3. Ввод источника ссылок
$linkSource = Read-Host "Enter source links.txt URL или путь к файлу"
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

# 4. Путь к 7-Zip
$zipPath = Read-Host "Enter path to 7z.exe (e.g., C:\Program Files\7-Zip\7z.exe)"
if (!(Test-Path $zipPath)) {
    Write-Color "7-Zip executable not found." 'Red'
    exit
}

# 5. Обработка ссылок
$links = Get-Content $tempLinksFile | Where-Object { $_ -match '^https?://' }
$totalLinks = $links.Count
$logFile = "$downloadPath\download_log.txt"

# Очистка лог-файла
"" | Out-File $logFile

$processedCount = 0

foreach ($link in $links) {
    $processedCount++
    $fileName = Split-Path -Path $link -Leaf
    if ([string]::IsNullOrEmpty($fileName)) {
        $fileName = "file" + $processedCount + ".download"
    }

    $destinationFile = Join-Path $downloadPath $fileName

    # Прогресс
    $percent = [math]::Round(($processedCount / $totalLinks) * 100, 2)
    Write-Color "Processing $processedCount of $totalLinks ($percent%) : $link" 'Cyan'

    # Загрузка файла
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

    # Распаковка архива
    $ext = [IO.Path]::GetExtension($fileName).ToLower()
    if ($ext -in @('.zip','.7z','.rar')) {
        Write-Color "Extracting: $fileName" 'Yellow'
        $archiveBaseName = [IO.Path]::GetFileNameWithoutExtension($fileName)

        # Создаем безопасное имя папки
        $safeFolderName = ($archiveBaseName -replace '[\\/:*?"<>|]', '_')
        $extractFolderPath = Join-Path $downloadPath $safeFolderName

        # Создать или очистить папку
        if (Test-Path $extractFolderPath) {
            Remove-Item "$extractFolderPath\*" -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            New-Item -ItemType Directory -Path $extractFolderPath | Out-Null
        }

        # Распаковка
    try {
        # Создаем массив аргументов без кавычек, указывая пути как есть
        $args = @(
            "x"          # распаковка
            "-y"         # автоматическое подтверждение
            "$destinationFile"             # архив файл
            "-o$extractFolderPath"          # папка для распаковки
        )

        # Выполняем команду
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

    # Размер файла
    if (Test-Path $destinationFile) {
        $fileSizeMB = [math]::Round((Get-Item $destinationFile).Length / 1MB, 2)
        Write-Color "File size: $fileSizeMB MB" 'Magenta'
    }

    Write-Host "" # Пустая строка для читаемости
}

# Итог
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