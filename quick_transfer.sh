#!/bin/bash

# Скрипт для быстрого переноса проекта uzbekservice_app
# Использование: ./quick_transfer.sh

echo "🚀 Подготовка проекта к переносу..."

# Проверка Git
if [ ! -d ".git" ]; then
    echo "📦 Инициализация Git репозитория..."
    git init
fi

# Добавление всех файлов
echo "📝 Добавление файлов в Git..."
git add .

# Проверка статуса
echo ""
echo "📊 Статус репозитория:"
git status --short | head -20

echo ""
echo "✅ Готово к переносу!"
echo ""
echo "📋 Следующие шаги:"
echo ""
echo "1. Создайте репозиторий на GitHub/GitLab:"
echo "   https://github.com/new"
echo ""
echo "2. Подключите удаленный репозиторий:"
echo "   git remote add origin https://github.com/ВАШ_USERNAME/uzbekservice_app.git"
echo ""
echo "3. Сделайте первый коммит и push:"
echo "   git commit -m 'Initial commit'"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "4. На новом MacBook:"
echo "   git clone https://github.com/ВАШ_USERNAME/uzbekservice_app.git"
echo "   cd uzbekservice_app"
echo "   flutter pub get"
echo "   flutter run -d chrome"
echo ""
echo "📖 Подробная инструкция в файле: TRANSFER_TO_NEW_MAC.md"

