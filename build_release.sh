#!/bin/bash

# Скрипт для сборки релизного AAB для Google Play Store

set -e

echo "🚀 Сборка релизного AAB для Google Play Store"
echo ""

cd "$(dirname "$0")"

# Проверка наличия keystore
if [ ! -f "android/odo_uz_keystore.jks" ]; then
  echo "❌ Keystore не найден!"
  echo "   Запустите: ./create_keystore.sh"
  exit 1
fi

# Проверка наличия key.properties
if [ ! -f "android/key.properties" ]; then
  echo "❌ key.properties не найден!"
  echo "   Создайте файл android/key.properties с паролями"
  exit 1
fi

# Очистка предыдущих сборок
echo "🧹 Очистка предыдущих сборок..."
flutter clean

# Получение зависимостей
echo "📦 Получение зависимостей..."
flutter pub get

# Сборка AAB
echo "🔨 Сборка релизного AAB..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Сборка успешно завершена!"
  echo ""
  echo "📦 Файл AAB находится в:"
  echo "   build/app/outputs/bundle/release/app-release.aab"
  echo ""
  echo "📤 Следующие шаги:"
  echo "   1. Загрузите app-release.aab в Google Play Console"
  echo "   2. Заполните информацию о приложении"
  echo "   3. Добавьте скриншоты и описание"
  echo "   4. Отправьте на проверку"
else
  echo ""
  echo "❌ Ошибка при сборке"
  exit 1
fi

