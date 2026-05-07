# Автоматически определяем путь к установщику
$EXEDIR = $MyInvocation.InvocationName | Split-Path
$SetupPath = Join-Path $EXEDIR "%{INSTALLER_EXE}"

if (-not (Test-Path $SetupPath)) {
    $SetupPath = Join-Path (Get-Location).Path "%{INSTALLER_EXE}"
}

# Инициализация переменной ReferrerUrl
$referrerLine = "ReferrerUrl="

# Пытаемся получить ReferrerUrl из Zone.Identifier с обработкой ошибок
try {
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
} catch {
    # В случае ошибки оставляем ReferrerUrl пустым
    $referrerLine = "ReferrerUrl="
}

# Генерация UUID и даты
try {
    $INSTALLATION_UUID = [System.Guid]::NewGuid().ToString().ToUpper()
} catch {
    # Если не удалось сгенерировать GUID, используем временную метку в формате GUID
    try {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $randomPart = Get-Random -Minimum 1000 -Maximum 9999
        # Форматируем как GUID: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
        $INSTALLATION_UUID = "$timestamp-$randomPart".ToUpper()
    } catch {
        # Если и это не удалось, используем простой формат
        $INSTALLATION_UUID = "INSTALL-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    }
}

try {
    $INSTALLATION_DATE = Get-Date -Format "yyyy-MM-dd HH:mm"
} catch {
    # В случае ошибки получения даты, используем фиксированное значение
    $INSTALLATION_DATE = "1970-01-01 00:00"
}

# Путь к выходному файлу
$OUTPUT_PATH = "%{standalone.path}\wfe.custom\wfe.custom.installation.properties"

# === Формируем содержимое installation.properties ===
$installationProps = @"
installation.uuid=$INSTALLATION_UUID
installation.date=$INSTALLATION_DATE
$referrerLine
statistic.report.url=%statistic.report.url
statistic.report.days.after.error=%statistic.report.days.after.error
"@

# Записываем файл (UTF-8 без BOM) с обработкой ошибок
try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($installationProps)
    [IO.File]::WriteAllBytes($OUTPUT_PATH, $bytes)
} catch {
    # В случае ошибки записи, создаем файл с минимальным содержимым
    $minimalProps = "installation.uuid=$INSTALLATION_UUID`ninstallation.date=$INSTALLATION_DATE`nReferrerUrl=`nstatistic.report.url=%{statistic.report.url}`nstatistic.report.days.after.error=%{statistic.report.days.after.error}"
    [IO.File]::WriteAllText($OUTPUT_PATH, $minimalProps, [System.Text.Encoding]::UTF8)
}