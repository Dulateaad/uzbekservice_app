#!/bin/bash

# Скрипт для сборки IPA для Diawi

set -e

PROJECT_DIR="$HOME/uzbekservice_app"

echo "==================================================================="
echo "  📱 Сборка IPA для Diawi"
echo "==================================================================="
echo ""

cd "$PROJECT_DIR"

# Шаг 1: Проверить Xcode
echo "1️⃣  Проверка Xcode..."
if pgrep -x "Xcode" > /dev/null; then
    echo "   ⚠️  Xcode открыт. Закройте его (Cmd + Q) и запустите скрипт снова."
    exit 1
fi
echo "   ✅ Xcode закрыт"
echo ""

# Шаг 2: Очистить
echo "2️⃣  Очистка..."
flutter clean
echo "   ✅ Очищено"
echo ""

# Шаг 3: Зависимости
echo "3️⃣  Получение зависимостей..."
flutter pub get
echo "   ✅ Готово"
echo ""

# Шаг 4: Установить CocoaPods
echo "4️⃣  Установка CocoaPods..."
cd ios
pod install --repo-update
cd ..
echo "   ✅ Готово"
echo ""

# Шаг 5: Собрать для устройства (без code signing)
echo "5️⃣  Сборка для устройства (без code signing)..."
echo "   ⚠️  Это может занять 5-10 минут..."
echo ""

# Попробуем собрать без code signing
flutter build ios --release --no-codesign 2>&1 | tee build.log || {
    echo ""
    echo "❌ Сборка не удалась из-за sandbox ошибок."
    echo ""
    echo "Попробуйте:"
    echo "1. Включить Full Disk Access для Xcode"
    echo "2. Перезапустить Mac"
    echo "3. Или использовать Xcode напрямую:"
    echo "   open ios/Runner.xcworkspace"
    echo ""
    exit 1
}

# Шаг 6: Создать IPA вручную из .app
echo ""
echo "6️⃣  Создание IPA файла..."
echo ""

APP_PATH=$(find build/ios/Release-iphoneos -name "*.app" -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ .app файл не найден!"
    echo "Проверьте build/ios/Release-iphoneos/"
    exit 1
fi

echo "Найден .app: $APP_PATH"

# Создать папку для IPA
mkdir -p build/ios/ipa
IPA_DIR="build/ios/ipa/Payload"
rm -rf "$IPA_DIR"
mkdir -p "$IPA_DIR"

# Скопировать .app в Payload
cp -r "$APP_PATH" "$IPA_DIR/"

# Создать IPA
cd build/ios/ipa
APP_NAME=$(basename "$APP_PATH" .app)
zip -r "${APP_NAME}.ipa" Payload/ > /dev/null
cd "$PROJECT_DIR"

IPA_FILE=$(find build/ios/ipa -name "*.ipa" 2>/dev/null | head -1)

if [ -n "$IPA_FILE" ]; then
    IPA_SIZE=$(du -h "$IPA_FILE" | cut -f1)
    echo ""
    echo "==================================================================="
    echo "✅ IPA создан!"
    echo "==================================================================="
    echo ""
    echo "📦 Файл: $(basename "$IPA_FILE")"
    echo "💾 Размер: $IPA_SIZE"
    echo "📁 Полный путь: $IPA_FILE"
    echo ""
    echo "📤 Загрузить на Diawi:"
    echo ""
    echo "   1. Откройте: https://www.diawi.com/"
    echo "   2. Перетащите файл: $IPA_FILE"
    echo "   3. Нажмите 'Upload'"
    echo "   4. Получите ссылку для распространения"
    echo ""
    echo "⚠️  ВАЖНО:"
    echo "   - Для установки на реальные устройства нужен code signing"
    echo "   - Без Apple Developer Program можно установить только на:"
    echo "     • Свое устройство через Xcode (7 дней)"
    echo "     • Устройства с зарегистрированными UDID (Ad-Hoc)"
    echo ""
else
    echo "❌ IPA не создан!"
    exit 1
fi

