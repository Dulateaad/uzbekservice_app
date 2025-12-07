#!/bin/bash

echo "🔧 Исправление прав доступа..."
echo ""

# Исправить права на DerivedData
sudo chown -R $(whoami) ~/XcodeDerivedData/
sudo chmod -R u+w ~/XcodeDerivedData/

# Исправить права на проект
sudo chown -R $(whoami) ~/uzbekservice_app/ios/
sudo chmod -R u+w ~/uzbekservice_app/ios/

# Исправить права на build директорию (если существует)
if [ -d ~/uzbekservice_app/build/ ]; then
    sudo chown -R $(whoami) ~/uzbekservice_app/build/
    sudo chmod -R u+w ~/uzbekservice_app/build/
fi

echo ""
echo "✅ Права доступа исправлены!"
echo ""
echo "Теперь:"
echo "1. Полностью закройте Xcode (Cmd + Q)"
echo "2. Откройте проект заново"
echo "3. Попробуйте Archive снова"

