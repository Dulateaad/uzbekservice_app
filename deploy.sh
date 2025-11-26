#!/bin/bash
# Скрипт для деплоя приложения на Firebase Hosting

echo "🔨 Сборка Flutter Web приложения..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Ошибка при сборке приложения"
    exit 1
fi

echo ""
echo "🚀 Деплой на Firebase Hosting..."
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Успешно задеплоено!"
    echo "🌐 Приложение доступно по адресам:"
    echo "   - https://studio-3898272712-a12a4.web.app"
    echo "   - https://studio-3898272712-a12a4.firebaseapp.com"
else
    echo "❌ Ошибка при деплое"
    exit 1
fi

