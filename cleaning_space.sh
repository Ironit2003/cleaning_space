#!/bin/bash
#ver 2.01

# Путь к проверяемой папке
# TARGET_DIR="//192.168.7.8/arhiv_video/test"
TARGET_DIR="/volume1/ARHIV_VIDEO/192.168.88.100"

# Лимит в байтах при достижении которого старый файлы будут улдаляться
# Для тестов 10 MB = 10485760 байт
# MAX_SIZE=10485760
# 7.8 TB = 8576190696653 байт   
MAX_SIZE=8576190696653
# Примерный размер одного файла (10 МБ)
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