#!/bin/bash

# 📱 Скрипт настройки iOS для ODO.UZ

echo "🚀 Настройка iOS для ODO.UZ..."

# Проверяем наличие Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не найден. Добавьте Flutter в PATH."
    exit 1
fi

# Проверяем наличие Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode не найден. Установите Xcode из App Store."
    exit 1
fi

# Устанавливаем CocoaPods
echo "📦 Установка CocoaPods..."
if command -v gem &> /dev/null; then
    sudo gem install cocoapods
else
    echo "❌ Ruby gem не найден. Установите Ruby."
    exit 1
fi

# Переходим в папку iOS и устанавливаем pods
echo "📱 Установка iOS зависимостей..."
cd ios
pod install
cd ..

# Проверяем сборку
echo "🔨 Проверка сборки iOS..."
flutter build ios --no-codesign

echo "✅ Настройка iOS завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Откройте ios/Runner.xcworkspace в Xcode"
echo "2. Настройте Bundle Identifier"
echo "3. Добавьте Apple Developer Account"
echo "4. Создайте Provisioning Profile"
echo "5. Соберите архив (Product → Archive)"
echo "6. Загрузите в App Store Connect"
echo ""
echo "📖 Подробная инструкция в TESTFLIGHT_SETUP.md"
