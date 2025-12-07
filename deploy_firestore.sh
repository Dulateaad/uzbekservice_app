#!/bin/bash

# Скрипт для развертывания правил безопасности и индексов Firestore

set -e

echo "🔥 Развертывание Firestore для ODO.UZ"
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

echo "📋 Проверка файлов..."
if [ ! -f "firestore.rules" ]; then
  echo "⚠️  Файл firestore.rules не найден!"
fi

if [ ! -f "firestore.indexes.json" ]; then
  echo "⚠️  Файл firestore.indexes.json не найден!"
fi

if [ ! -f "storage.rules" ]; then
  echo "⚠️  Файл storage.rules не найден!"
fi

echo "✅ Проверка завершена"
echo ""

# Меню выбора
echo "Что вы хотите развернуть?"
echo "1) Только правила Firestore (firestore.rules)"
echo "2) Только индексы Firestore (firestore.indexes.json)"
echo "3) Firestore (правила + индексы)"
echo "4) Только правила Storage (storage.rules)"
echo "5) Все (Firestore + Storage)"
echo "6) Отмена"
echo ""
read -p "Выберите вариант (1-6): " choice

case $choice in
  1)
    echo ""
    echo "🔒 Развертывание правил безопасности Firestore..."
    firebase deploy --only firestore:rules
    ;;
  2)
    echo ""
    echo "📇 Развертывание индексов Firestore..."
    firebase deploy --only firestore:indexes
    echo ""
    echo "⚠️  Примечание: Создание индексов может занять несколько минут."
    echo "   Проверьте статус в Firebase Console:"
    echo "   https://console.firebase.google.com/project/odo-uz-1f4d9/firestore/indexes"
    ;;
  3)
    echo ""
    echo "🔒 Развертывание правил безопасности Firestore..."
    firebase deploy --only firestore:rules
    echo ""
    echo "📇 Развертывание индексов Firestore..."
    firebase deploy --only firestore:indexes
    echo ""
    echo "⚠️  Примечание: Создание индексов может занять несколько минут."
    echo "   Проверьте статус в Firebase Console:"
    echo "   https://console.firebase.google.com/project/odo-uz-1f4d9/firestore/indexes"
    ;;
  4)
    echo ""
    echo "📦 Развертывание правил безопасности Storage..."
    firebase deploy --only storage
    ;;
  5)
    echo ""
    echo "🔒 Развертывание правил безопасности Firestore..."
    firebase deploy --only firestore:rules
    echo ""
    echo "📇 Развертывание индексов Firestore..."
    firebase deploy --only firestore:indexes
    echo ""
    echo "📦 Развертывание правил безопасности Storage..."
    firebase deploy --only storage
    echo ""
    echo "⚠️  Примечание: Создание индексов может занять несколько минут."
    echo "   Проверьте статус в Firebase Console:"
    echo "   https://console.firebase.google.com/project/odo-uz-1f4d9/firestore/indexes"
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
echo "📊 Проверьте статус в Firebase Console:"
echo "   https://console.firebase.google.com/project/odo-uz-1f4d9/firestore"

