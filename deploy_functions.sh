#!/bin/bash

# Скрипт для развертывания Cloud Functions

set -e

echo "☁️ Развертывание Cloud Functions для ODO.UZ"
echo ""

cd "$(dirname "$0")"

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

# Проверка наличия функций
if [ ! -d "functions" ]; then
  echo "❌ Директория functions не найдена!"
  exit 1
fi

# Установка зависимостей
echo "📦 Установка зависимостей..."
cd functions
if [ ! -d "node_modules" ]; then
  npm install
else
  echo "✅ Зависимости уже установлены"
fi
cd ..

# Меню выбора
echo ""
echo "Что вы хотите развернуть?"
echo "1) Все функции"
echo "2) Только sendOrderNotification (уведомления о заказах)"
echo "3) Только sendChatNotification (уведомления о сообщениях)"
echo "4) Только sendOrderStatusNotification (уведомления о статусе)"
echo "5) Только sendReviewNotification (уведомления об отзывах)"
echo "6) Отмена"
echo ""
read -p "Выберите вариант (1-6): " choice

case $choice in
  1)
    echo ""
    echo "☁️ Развертывание всех функций..."
    firebase deploy --only functions
    ;;
  2)
    echo ""
    echo "☁️ Развертывание sendOrderNotification..."
    firebase deploy --only functions:sendOrderNotification
    ;;
  3)
    echo ""
    echo "☁️ Развертывание sendChatNotification..."
    firebase deploy --only functions:sendChatNotification
    ;;
  4)
    echo ""
    echo "☁️ Развертывание sendOrderStatusNotification..."
    firebase deploy --only functions:sendOrderStatusNotification
    ;;
  5)
    echo ""
    echo "☁️ Развертывание sendReviewNotification..."
    firebase deploy --only functions:sendReviewNotification
    ;;
  6)
    echo "Отменено"
    exit 0
    ;;
  *)
    echo "❌ Неверный выбор"
    exit 1
    ;;
esac

echo ""
echo "✅ Развертывание завершено!"
echo ""
echo "📊 Проверьте функции в Firebase Console:"
echo "   https://console.firebase.google.com/project/odo-uz-1f4d9/functions"
echo ""
echo "📋 Просмотр логов:"
echo "   firebase functions:log"

