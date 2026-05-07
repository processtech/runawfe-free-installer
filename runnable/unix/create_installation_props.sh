#!/bin/bash

# Генерация UUID и даты
if command -v uuidgen &> /dev/null; then
    INSTALLATION_UUID=$(uuidgen | tr '[:lower:]' '[:upper:]')
elif [ -f /proc/sys/kernel/random/uuid ]; then
    INSTALLATION_UUID=$(cat /proc/sys/kernel/random/uuid | tr '[:lower:]' '[:upper:]')
else
    # Если не удалось сгенерировать GUID, используем временную метку
    TIMESTAMP=$(date +"%Y%m%d%H%M%S")
    RANDOM_PART=$((RANDOM % 9000 + 1000))
    INSTALLATION_UUID="${TIMESTAMP}-${RANDOM_PART}"
fi

INSTALLATION_DATE=$(date +"%Y-%m-%d %H:%M" 2>/dev/null || echo "1970-01-01 00:00")

# Путь к выходному файлу
OUTPUT_PATH="%{standalone.path}/wfe.custom/wfe.custom.installation.properties"

mkdir -p "$(dirname "$OUTPUT_PATH")"

# Формируем содержимое installation.properties
cat > "$OUTPUT_PATH" << EOF
installation.uuid=$INSTALLATION_UUID
installation.date=$INSTALLATION_DATE
ReferrerUrl=
statistic.report.url=%{statistic.report.url}
statistic.report.days.after.error=%{statistic.report.days.after.error}
EOF

# Проверяем успешность записи
if [ $? -eq 0 ]; then
    echo "Файл $OUTPUT_PATH успешно создан"
else
    echo "Ошибка при создании файла $OUTPUT_PATH" >&2
    exit 1
fi