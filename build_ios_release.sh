#!/bin/bash

# Скрипт для сборки iOS приложения для TestFlight

set -e

echo "🍎 Сборка iOS приложения для TestFlight"
echo ""

cd "$(dirname "$0")"

# Проверка Flutter
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter не установлен!"
  exit 1
fi

# Очистка
echo "🧹 Очистка проекта..."
flutter clean

# Получение зависимостей
echo "📦 Получение зависимостей..."
flutter pub get

# Обновление iOS зависимостей
echo "📦 Обновление iOS зависимостей..."
cd ios
pod install
cd ..

# Проверка версии
echo "📋 Текущая версия:"
grep "version:" pubspec.yaml

echo ""
read -p "Увеличить build number? (y/n): " increase_build

if [ "$increase_build" = "y" ]; then
  # Получаем текущую версию
  CURRENT_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
  VERSION_NAME=$(echo $CURRENT_VERSION | cut -d'+' -f1)
  BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)
  
  # Увеличиваем build number
  NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
  NEW_VERSION="$VERSION_NAME+$NEW_BUILD_NUMBER"
  
  # Обновляем pubspec.yaml
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/version: .*/version: $NEW_VERSION/" pubspec.yaml
  else
    # Linux
    sed -i "s/version: .*/version: $NEW_VERSION/" pubspec.yaml
  fi
  
  echo "✅ Build number увеличен: $BUILD_NUMBER → $NEW_BUILD_NUMBER"
fi

# Сборка iOS
echo ""
echo "🔨 Сборка iOS приложения..."
flutter build ios --release

echo ""
echo "✅ Сборка завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Откройте Xcode:"
echo "   open ios/Runner.xcworkspace"
echo ""
echo "2. Выберите 'Any iOS Device' в схеме"
echo ""
echo "3. Product → Archive"
echo ""
echo "4. В Organizer: Distribute App → App Store Connect → Upload"
echo ""
echo "📖 Подробная инструкция: TESTFLIGHT_SETUP.md"

