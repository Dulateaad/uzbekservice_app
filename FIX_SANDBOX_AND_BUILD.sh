#!/bin/bash

# Скрипт для исправления sandbox и сборки IPA

set -e

PROJECT_DIR="$HOME/uzbekservice_app"

echo "==================================================================="
echo "  🔧 Исправление Sandbox и сборка IPA для TestFlight"
echo "==================================================================="
echo ""

cd "$PROJECT_DIR"

# Шаг 1: Исправить права (требует пароль)
echo "1️⃣  Исправление прав на DerivedData..."
echo "   ⚠️  Введите пароль Mac при запросе:"
sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData/
sudo chmod -R u+w ~/Library/Developer/Xcode/DerivedData/
echo "   ✅ Права исправлены"
echo ""

# Шаг 2: Проверить Full Disk Access
echo "2️⃣  Проверка Full Disk Access..."
echo ""
echo "   ⚠️  ВАЖНО: Убедитесь, что Xcode включен в:"
echo "      System Settings → Privacy & Security → Full Disk Access"
echo ""
read -p "   Xcode включен в Full Disk Access? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "   ❌ Сначала включите Full Disk Access для Xcode!"
    echo "   Затем перезапустите Mac и запустите скрипт снова."
    exit 1
fi
echo ""

# Шаг 3: Очистить старые build файлы
echo "3️⃣  Очистка старых build файлов..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
flutter clean
echo "   ✅ Очищено"
echo ""

# Шаг 4: Получить зависимости
echo "4️⃣  Получение зависимостей..."
flutter pub get
echo "   ✅ Готово"
echo ""

# Шаг 5: Сборка IPA
echo "5️⃣  Сборка IPA (это займет 5-15 минут)..."
echo ""
flutter build ipa --release

echo ""
echo "==================================================================="
echo ""

# Проверить результат
IPA_PATH=$(find build/ios/ipa -name "*.ipa" 2>/dev/null | head -1)

if [ -n "$IPA_PATH" ]; then
    IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
    IPA_NAME=$(basename "$IPA_PATH")
    
    echo "✅ УСПЕХ! IPA создан!"
    echo ""
    echo "📦 Файл: $IPA_NAME"
    echo "💾 Размер: $IPA_SIZE"
    echo "📁 Полный путь: $IPA_PATH"
    echo ""
    echo "📤 Загрузить в TestFlight:"
    echo ""
    echo "   1. Откройте Transporter app (из Mac App Store)"
    echo "   2. Перетащите файл: $IPA_PATH"
    echo "   3. Нажмите 'Deliver'"
    echo ""
    echo "   Или используйте команду:"
    echo "   open -a Transporter \"$IPA_PATH\""
    echo ""
else
    echo "❌ Build не удался - IPA не создан"
    echo ""
    echo "Проверьте ошибки выше."
    echo ""
    exit 1
fi

