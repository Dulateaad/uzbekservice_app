#!/bin/bash

# Скрипт для проверки OneID Backend

echo "🔍 Проверка OneID Backend..."
echo ""

# Проверяем, указан ли backend URL в конфигурации
BACKEND_URL=$(grep -oP "backendUrl = '\K[^']+" lib/config/oneid_config.dart 2>/dev/null || echo "")

if [ -z "$BACKEND_URL" ] || [ "$BACKEND_URL" = "https://your-render-service.onrender.com" ]; then
    echo "❌ Backend URL не настроен!"
    echo "   Текущее значение: $BACKEND_URL"
    echo ""
    echo "📝 Для настройки:"
    echo "   1. Разверните backend на Render (см. ONEID_SETUP.md)"
    echo "   2. Получите URL вашего сервиса"
    echo "   3. Обновите lib/config/oneid_config.dart"
    exit 1
fi

echo "✅ Backend URL найден: $BACKEND_URL"
echo ""

# Проверяем доступность backend
echo "🔍 Проверка доступности backend..."
HEALTH_CHECK=$(curl -s "$BACKEND_URL/health" 2>/dev/null || echo "")

if [ -z "$HEALTH_CHECK" ]; then
    echo "❌ Backend недоступен!"
    echo "   Проверьте, что сервис развернут на Render"
    exit 1
fi

if echo "$HEALTH_CHECK" | grep -q '"ok"'; then
    echo "✅ Backend работает!"
    echo "   Ответ: $HEALTH_CHECK"
else
    echo "⚠️  Backend отвечает, но health check не прошел"
    echo "   Ответ: $HEALTH_CHECK"
fi

echo ""
echo "📋 Следующие шаги:"
echo "   1. Убедитесь, что в OneID кабинете добавлены Redirect URIs:"
echo "      - $BACKEND_URL/auth/oneid/callback"
echo "      - odo.app://auth/oneid/callback"
echo "   2. Проверьте, что ONEID_CLIENT_SECRET правильный"
echo "   3. Протестируйте авторизацию в приложении"

