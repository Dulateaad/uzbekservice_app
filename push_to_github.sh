#!/bin/bash

# Автоматический скрипт для push в GitHub

set -e

PROJECT_DIR="$HOME/uzbekservice_app"

echo "🚀 Push изменений в GitHub"
echo "=========================="
echo ""

cd "$PROJECT_DIR"

echo "📍 Текущая папка: $(pwd)"
echo ""

# Проверить статус
echo "1️⃣  Проверка изменений..."
git status --short
echo ""

# Спросить подтверждение
read -p "Продолжить push? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Отменено."
    exit 1
fi

# Добавить файлы
echo ""
echo "2️⃣  Добавление файлов..."
git add .
echo "✅ Файлы добавлены"
echo ""

# Commit
echo "3️⃣  Создание commit..."
git commit -m "Latest changes" || echo "Нет изменений для commit"
echo "✅ Commit создан"
echo ""

# Push
echo "4️⃣  Push в GitHub..."
git push
echo ""
echo "✅ Push завершен!"
echo ""
echo "Проверьте build: https://github.com/Dulateaad/uzbekservice_app/actions"

