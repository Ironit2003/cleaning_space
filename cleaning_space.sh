#!/bin/bash
#ver 2.0

# Путь к проверяемой папке (для теста в Git Bash)
TARGET_DIR="//192.168.7.8/arhiv_video/test"
# Для Synology NAS раскомментируйте строку ниже и закомментируйте строку выше:
# TARGET_DIR="/volume1/ARHIV_VIDEO/192.168.88.100"

# Лимит в байтах (для теста 20 МБ)
MAX_SIZE=20971520
# Для реальной работы на 8 ТБ раскомментируйте строку ниже:
# MAX_SIZE=8796093022208

# Примерный размер одного файла (для теста 10 МБ)
FILE_SIZE=10485760

echo "Проверяем директорию: $TARGET_DIR"

# Расчёт размера папки
CURRENT_SIZE=$(du -sb "$TARGET_DIR" 2>/dev/null | awk '{print $1}')

# Если папка пустая или du вернул ошибку/пустоту, ставим 0
if [ -z "$CURRENT_SIZE" ]; then
    CURRENT_SIZE=0
fi

echo "Текущий размер папки: $CURRENT_SIZE байт (Лимит: $MAX_SIZE байт)"

# Проверка, что CURRENT_SIZE это действительно число
if ! [[ "$CURRENT_SIZE" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: Не удалось корректно определить размер папки. Проверьте путь $TARGET_DIR"
    exit 1
fi

if [ "$CURRENT_SIZE" -gt "$MAX_SIZE" ]; then
    
    # Расчет сколько файлов нужно удалить
    FILE_COUNT=$(( (CURRENT_SIZE - MAX_SIZE + FILE_SIZE - 1) / FILE_SIZE ))
    
    echo "Необходимо удалить файлов: $FILE_COUNT"
    echo "Превышен лимит! Удаление файлов..."
    
    # find запускается ОДИН раз. 
    # Он находит файлы, сортирует и с помощью 'head -n' берет ровно $FILE_COUNT штук.
    find "$TARGET_DIR" -type f -printf '%T+ %p\n' 2>/dev/null | sort | head -n "$FILE_COUNT" | cut -d' ' -f2- | while read -r OLDEST_FILE; do
        if [ -n "$OLDEST_FILE" ]; then
            echo "Удаляем старый файл: $OLDEST_FILE"
            rm -f "$OLDEST_FILE"
        fi
    done

    echo "Удаление пачки завершено."
else
    echo "Размер в норме. Действия не требуются."
fi