#!/bin/bash

# Скрипт для создания keystore для подписи релизных сборок
# ВАЖНО: Сохраните пароли и информацию о keystore в безопасном месте!

echo "🔐 Создание keystore для подписи релизных сборок ODO.UZ"
echo ""
echo "Вам будет предложено ввести:"
echo "  - Пароль для keystore (минимум 6 символов)"
echo "  - Пароль для ключа (может быть таким же)"
echo "  - Информацию о владельце"
echo ""
echo "⚠️  ВАЖНО: Сохраните эти данные в безопасном месте!"
echo "   Без keystore вы не сможете обновлять приложение в Play Store!"
echo ""

cd "$(dirname "$0")/android"

keytool -genkey -v -keystore odo_uz_keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias odo_uz_key \
  -storetype JKS

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Keystore успешно создан: android/odo_uz_keystore.jks"
  echo ""
  echo "📝 Теперь обновите android/key.properties:"
  echo "   storePassword=ВАШ_ПАРОЛЬ_КЕЙСТОРА"
  echo "   keyPassword=ВАШ_ПАРОЛЬ_КЛЮЧА"
  echo "   keyAlias=odo_uz_key"
  echo "   storeFile=../odo_uz_keystore.jks"
  echo ""
  echo "⚠️  Добавьте android/key.properties и android/odo_uz_keystore.jks в .gitignore!"
else
  echo ""
  echo "❌ Ошибка при создании keystore"
  exit 1
fi

