#!/bin/bash

# Скрипт для настройки Firebase для iOS

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  📱 Настройка Firebase для iOS                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Проверяем наличие файла в Downloads
if [ -f ~/Downloads/GoogleService-Info.plist ]; then
    echo "✅ Найден GoogleService-Info.plist в Downloads"
    echo "📋 Копирую файл в проект..."
    cp ~/Downloads/GoogleService-Info.plist ios/Runner/
    echo "✅ Файл скопирован в ios/Runner/"
    echo ""
    ls -lh ios/Runner/GoogleService-Info.plist
    echo ""
    echo "✅ Готово! Теперь выполните:"
    echo "   cd ios && pod install && cd .."
else
    echo "❌ Файл GoogleService-Info.plist не найден в Downloads"
    echo ""
    echo "📥 Инструкция по скачиванию:"
    echo "1. Откройте: https://console.firebase.google.com/project/odo-uz-1f4d9/settings/general"
    echo "2. В разделе 'Your apps' нажмите 'Add app' → iOS"
    echo "3. Введите Bundle ID: com.example.uzbekserviceApp"
    echo "4. Нажмите 'Register app'"
    echo "5. Скачайте GoogleService-Info.plist"
    echo "6. Запустите этот скрипт снова: ./setup_ios_firebase.sh"
    echo ""
fi

