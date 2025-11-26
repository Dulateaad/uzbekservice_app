# Инструкция по деплою OneID Backend на Render

## Шаги для деплоя

### 1. Подготовка репозитория

Убедитесь, что все изменения закоммичены и запушены:
```bash
cd server-oneid
git add .
git commit -m "Ready for Render deployment"
git push origin main
```

### 2. Создание Web Service на Render

1. Зайдите на [dashboard.render.com](https://dashboard.render.com)
2. Нажмите **"New"** → **"Web Service"**
3. Выберите репозиторий `Dulateaad/odo-oneid-backend`
4. Нажмите **"Connect"**

### 3. Настройка сервиса

**Основные настройки:**
- **Name:** `odo-oneid-backend` (или любое другое имя)
- **Root Directory:** `server-oneid`
- **Runtime:** `Node`
- **Build Command:** `npm install`
- **Start Command:** `npm start`
- **Health Check Path:** `/health`

### 4. Environment Variables

Добавьте следующие переменные окружения в разделе **"Environment"**:

```env
ONEID_CLIENT_ID=odo_uz
ONEID_CLIENT_SECRET=ваш_секрет_здесь

# Эти переменные имеют значения по умолчанию, но можно указать явно:
ONEID_BASE_URL=https://sso.egov.uz
ONEID_AUTH_URL=https://sso.egov.uz/sso/oauth/Authorization.do
ONEID_TOKEN_URL=https://sso.egov.uz/sso/oauth/Token.do
ONEID_USERINFO_URL=https://sso.egov.uz/sso/oauth/Resource.do

# Обновите после деплоя (замените your-service-name на реальное имя):
ONEID_REDIRECT_WEB=https://your-service-name.onrender.com/auth/oneid/callback
ONEID_REDIRECT_MOBILE=odo.app://auth/oneid/callback
APP_SCHEME=odo.app
ALLOWED_ORIGINS=http://localhost:8124,https://odo.uz,https://your-service-name.onrender.com
PORT=8787
```

⚠️ **Важно:** После первого деплоя получите URL вашего сервиса (например, `https://odo-oneid-backend.onrender.com`) и обновите:
- `ONEID_REDIRECT_WEB` → `https://odo-oneid-backend.onrender.com/auth/oneid/callback`
- `ALLOWED_ORIGINS` → добавьте ваш Render домен

### 5. Создание сервиса

Нажмите **"Create Web Service"**. Render начнет деплой (займет 2-3 минуты).

### 6. Проверка деплоя

После успешного деплоя:

1. Откройте в браузере: `https://your-service-name.onrender.com/health`
   - Должно вернуть: `{"ok":true}`

2. Если health check не проходит, проверьте логи в Render Dashboard

### 7. Настройка OneID

В кабинете OneID добавьте следующие Redirect URIs:
- `https://your-service-name.onrender.com/auth/oneid/callback`
- `odo.app://auth/oneid/callback`

### 8. Обновление Flutter приложения

После получения URL вашего сервиса на Render, обновите `lib/config/oneid_config.dart`:

```dart
static const String backendUrl = 'https://your-service-name.onrender.com';
```

## Проверка работы

1. **Health Check:**
   ```bash
   curl https://your-service-name.onrender.com/health
   ```
   Ожидаемый ответ: `{"ok":true}`

2. **Тест обмена кода на токен:**
   ```bash
   curl -X POST https://your-service-name.onrender.com/api/oneid/token \
     -H "Content-Type: application/json" \
     -d '{"code":"test_code","redirectUri":"odo.app://auth/oneid/callback"}'
   ```

## Troubleshooting

### Проблема: Сервис не запускается
- Проверьте логи в Render Dashboard
- Убедитесь, что `package.json` содержит правильные скрипты
- Проверьте, что все зависимости указаны в `package.json`

### Проблема: Health check не проходит
- Убедитесь, что порт указан правильно (Render автоматически устанавливает PORT)
- Проверьте, что путь `/health` существует в коде

### Проблема: CORS ошибки
- Проверьте `ALLOWED_ORIGINS` в environment variables
- Убедитесь, что домен вашего Flutter приложения добавлен в список

### Проблема: OneID возвращает ошибку
- Проверьте, что все Redirect URIs правильно настроены в OneID
- Убедитесь, что `ONEID_CLIENT_ID` и `ONEID_CLIENT_SECRET` правильные
- Проверьте логи в Render Dashboard для деталей ошибки

## Стоимость

Render предоставляет бесплатный план с ограничениями:
- Сервис засыпает после 15 минут неактивности
- Первый запрос после пробуждения может занять 30-50 секунд (cold start)
- Для production рекомендуется использовать платный план

## Следующие шаги

После успешного деплоя:
1. Обновите `backendUrl` в Flutter приложении
2. Протестируйте авторизацию через OneID
3. Настройте мониторинг и логирование (опционально)

