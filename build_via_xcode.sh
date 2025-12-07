#!/bin/bash

echo "🔨 Сборка через Xcode напрямую (обходит Sandbox проблемы)"
echo "=========================================================="
echo ""

# Открываем проект в Xcode
echo "📱 Открываю проект в Xcode..."
open ~/uzbekservice_app/ios/Runner.xcworkspace

echo ""
echo "✅ Xcode открыт!"
echo ""
echo "📋 ИНСТРУКЦИИ ДЛЯ СБОРКИ В XCODE:"
echo ""
echo "1. В Xcode выберите 'Any iOS Device' (не симулятор!)"
echo "2. Product → Scheme → Edit Scheme..."
echo "3. Выберите 'Archive' в левой колонке"
echo "4. Build Configuration: выберите 'Release'"
echo "5. Нажмите Close"
echo "6. Product → Archive"
echo ""
echo "💡 Этот метод часто обходит Sandbox проблемы!"
echo ""

