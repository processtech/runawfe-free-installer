#!/bin/sh
# Скрипт для установки/удаления ярлыка для рабочего стола текущего пользователя
# Первый аргумент: имя ярлыка (например, "Developer studio" или "Task notifier")
# Второй аргумент (опционально): --delete для удаления ярлыка

SHORTCUT_NAME="$1"
if [ -z "$SHORTCUT_NAME" ]; then
    exit 0
fi

# Определяем папку рабочего стола текущего пользователя
DESKTOP_DIR="$HOME/Desktop"
if command -v xdg-user-dir >/dev/null 2>&1; then
    XDG_DESKTOP=$(xdg-user-dir DESKTOP 2>/dev/null)
    if [ -n "$XDG_DESKTOP" ] && [ -d "$XDG_DESKTOP" ]; then
        DESKTOP_DIR="$XDG_DESKTOP"
    fi
fi
# Альтернативное название на русском
if [ ! -d "$DESKTOP_DIR" ] && [ -d "$HOME/Рабочий стол" ]; then
    DESKTOP_DIR="$HOME/Рабочий стол"
fi

DESKTOP_TARGET="$DESKTOP_DIR/$SHORTCUT_NAME.desktop"

if [ "$2" = "--delete" ]; then
    rm -f "$DESKTOP_TARGET" 2>/dev/null || true
    exit 0
fi

DESKTOP_SOURCE="/usr/share/applications/$SHORTCUT_NAME.desktop"
if [ ! -f "$DESKTOP_SOURCE" ]; then
    exit 0
fi

# Проверяем, не существует ли уже ярлык (чтобы избежать дублирования)
if [ ! -f "$DESKTOP_TARGET" ]; then
    mkdir -p "$DESKTOP_DIR"
    cp "$DESKTOP_SOURCE" "$DESKTOP_TARGET"
fi

exit 0