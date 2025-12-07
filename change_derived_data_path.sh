#!/bin/bash

echo "🔧 Изменение пути DerivedData для обхода Sandbox проблем"
echo "========================================================"
echo ""

# Создаем новый путь для DerivedData в домашней директории
NEW_DERIVED_DATA="$HOME/XcodeDerivedData"

echo "📁 Создаю новый путь для DerivedData: $NEW_DERIVED_DATA"
mkdir -p "$NEW_DERIVED_DATA"

echo ""
echo "✅ Новый путь создан!"
echo ""
echo "📋 ИНСТРУКЦИИ:"
echo ""
echo "1. Откройте Xcode"
echo "2. Xcode → Settings (или Preferences)"
echo "3. Перейдите на вкладку 'Locations'"
echo "4. В разделе 'Derived Data' нажмите 'Advanced...'"
echo "5. Выберите 'Custom' и укажите путь:"
echo "   $NEW_DERIVED_DATA"
echo "6. Нажмите 'Done'"
echo "7. Закройте и переоткройте Xcode"
echo "8. Попробуйте сборку снова"
echo ""
echo "💡 Это часто решает Sandbox проблемы!"
echo ""

