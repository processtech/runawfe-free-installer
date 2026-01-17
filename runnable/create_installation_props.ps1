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
    $zoneContent = & powershell -Command "(Get-Content '$SetupPath' -Stream Zone.Identifier -ErrorAction SilentlyContinue)"
    if ($zoneContent -and $zoneContent.Length -gt 2) {
        $line = $zoneContent[2].Trim()
        if ($line -like "ReferrerUrl:*") {
            $urlPart = $line.Substring("ReferrerUrl:".Length).Trim()
            $referrerLine = "ReferrerUrl=$urlPart"
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