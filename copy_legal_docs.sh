#!/bin/bash

# Скрипт для копирования юридических документов в build/web

set -e

echo "📄 Копирование юридических документов..."

cd "$(dirname "$0")"

# Проверка наличия директории build/web
if [ ! -d "build/web" ]; then
    echo "⚠️  Директория build/web не найдена. Сначала выполните: flutter build web"
    exit 1
fi

# Копирование файлов
if [ -f "web/privacy-policy.html" ]; then
    cp web/privacy-policy.html build/web/
    echo "✅ Политика конфиденциальности скопирована"
else
    echo "❌ Файл web/privacy-policy.html не найден"
    exit 1
fi

if [ -f "web/terms-of-service.html" ]; then
    cp web/terms-of-service.html build/web/
    echo "✅ Пользовательское соглашение скопировано"
else
    echo "❌ Файл web/terms-of-service.html не найден"
    exit 1
fi

echo ""
echo "✅ Все юридические документы скопированы в build/web"
echo ""
echo "🔗 URL для Play Store:"
echo "  - https://odo-uz-1f4d9.web.app/privacy-policy.html"
echo "  - https://odo-uz-1f4d9.web.app/terms-of-service.html"

