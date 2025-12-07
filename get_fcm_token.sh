#!/bin/bash

# Скрипт для получения FCM токена из Firestore

echo "🔍 Поиск FCM токенов в Firestore..."
echo ""

# Проверка наличия Firebase CLI
if ! command -v firebase &> /dev/null; then
  echo "❌ Firebase CLI не установлен!"
  echo "   Установите: npm install -g firebase-tools"
  exit 1
fi

# Проверка авторизации
if ! firebase projects:list &> /dev/null; then
  echo "❌ Не авторизованы в Firebase!"
  echo "   Выполните: firebase login"
  exit 1
fi

echo "📋 Получение токенов из Firestore..."
echo ""

# Используем Firestore REST API для получения токенов
# (Требует настройки Firebase Admin SDK или использования консоли)

echo "💡 Для получения токена:"
echo ""
echo "1. Откройте Firebase Console:"
echo "   https://console.firebase.google.com/project/odo-uz-1f4d9/firestore"
echo ""
echo "2. Перейдите в коллекцию 'users'"
echo ""
echo "3. Найдите документ вашего пользователя"
echo ""
echo "4. Скопируйте токен из поля 'deviceTokens' (первый элемент массива)"
echo ""
echo "Или используйте логи приложения:"
echo "   - Запустите: flutter run"
echo "   - Войдите в аккаунт"
echo "   - Найдите в логах: '📱 FCM Token получен: ...'"
echo ""

# Альтернатива: использовать gcloud для получения данных
if command -v gcloud &> /dev/null; then
  echo "🔧 Попытка получить токены через gcloud..."
  echo ""
  
  # Получаем список пользователей
  gcloud firestore documents list \
    --project=odo-uz-1f4d9 \
    --collection-id=users \
    --format=json 2>/dev/null | \
    jq -r '.[] | select(.fields.deviceTokens != null) | "\(.name) -> \(.fields.deviceTokens.arrayValue.values[0].stringValue)"' 2>/dev/null
  
  if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Токены получены!"
  else
    echo "⚠️ Не удалось получить токены через gcloud"
    echo "   Используйте Firebase Console или логи приложения"
  fi
else
  echo "💡 Для автоматического получения установите gcloud CLI:"
  echo "   https://cloud.google.com/sdk/docs/install"
fi

echo ""
echo "📱 После получения токена отправьте тестовое уведомление:"
echo "   https://console.firebase.google.com/project/odo-uz-1f4d9/notification"

