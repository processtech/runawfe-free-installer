# Автоматически определяем путь к установщику
$EXEDIR = $MyInvocation.InvocationName | Split-Path
$EXEFILE = "%APP_NAME%-%APP_VER%.exe"
$SetupPath = Join-Path $EXEDIR $EXEFILE

if (-not (Test-Path $SetupPath)) {
    $SetupPath = Join-Path (Get-Location).Path $EXEFILE
}

# Читаем ReferrerUrl из Zone.Identifier
$referrerLine = "ReferrerUrl="

if (Test-Path $SetupPath) {
    # Приводим путь к абсолютному виду для [System.IO.File]
    $fullPath = [System.IO.Path]::GetFullPath($SetupPath)
    $zoneStreamPath = "$fullPath:Zone.Identifier"

    if ([System.IO.File]::Exists($zoneStreamPath)) {
        $zoneContent = [System.IO.File]::ReadAllLines($zoneStreamPath)
        
        if ($zoneContent -and $zoneContent.Count -ge 3) {
            $refLine = $zoneContent | Where-Object { $_ -like "ReferrerUrl=*" }
            if ($refLine) {
                 $urlPart = $refLine.Split('=')[1].Trim()
                 $referrerLine = "ReferrerUrl=$urlPart"
            }
        }
    }
}

# Генерация UUID и даты
$INSTALLATION_UUID = [System.Guid]::NewGuid().ToString().ToUpper()
$INSTALLATION_DATE = Get-Date -Format "yyyy-MM-dd HH:mm"

# Путь к выходному файлу
$OUTPUT_PATH = "%{INSTALL_PATH}\%{appserver.subpath}\standalone\wfe.custom\wfe.custom.installation.properties"

# === Формируем содержимое installation.properties ===
$installationProps = @"
installation.uuid=$INSTALLATION_UUID
installation.date=$INSTALLATION_DATE
$referrerLine
statistic.report.url=%statistic.report.url
statistic.report.days.after.error=%statistic.report.days.after.error
"@

# Записываем файл (UTF-8 без BOM)
$bytes = [System.Text.Encoding]::UTF8.GetBytes($installationProps)
[IO.File]::WriteAllBytes($OUTPUT_PATH, $bytes)