# Настройка OneID для Odo

## Текущий статус

✅ Backend код готов (`server-oneid/`)
✅ Flutter интеграция готова
⚠️ Нужно развернуть backend на Render
⚠️ Нужно обновить конфигурацию Flutter приложения

## Шаг 1: Проверка backend на Render

1. Зайдите на [dashboard.render.com](https://dashboard.render.com)
2. Проверьте, есть ли сервис `odo-oneid-backend`
3. Если есть — скопируйте его URL (например: `https://odo-oneid-backend.onrender.com`)
4. Если нет — переходите к Шагу 2

## Шаг 2: Деплой backend на Render (если еще не развернут)

### 2.1. Подготовка репозитория

```bash
cd server-oneid
git status  # Проверьте, что все изменения сохранены
git add .
git commit -m "Ready for Render deployment"
git push origin main
```

### 2.2. Создание Web Service на Render

1. Зайдите на [dashboard.render.com](https://dashboard.render.com)
2. Нажмите **"New"** → **"Web Service"**
3. Подключите репозиторий `Dulateaad/odo-oneid-backend`
   - Если репозитория нет, создайте его на GitHub и загрузите код из `server-oneid/`
4. Настройки сервиса:
   - **Name:** `odo-oneid-backend`
   - **Root Directory:** `server-oneid`
   - **Runtime:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Health Check Path:** `/health`

### 2.3. Environment Variables

Добавьте в разделе **"Environment"**:

```env
ONEID_CLIENT_ID=odo_uz
ONEID_CLIENT_SECRET=ваш_секрет_здесь

# Эти переменные имеют значения по умолчанию:
ONEID_BASE_URL=https://sso.egov.uz
ONEID_AUTH_URL=https://sso.egov.uz/sso/oauth/Authorization.do
ONEID_TOKEN_URL=https://sso.egov.uz/sso/oauth/Token.do
ONEID_USERINFO_URL=https://sso.egov.uz/sso/oauth/Resource.do

# Обновите после деплоя (замените your-service-name):
ONEID_REDIRECT_WEB=https://your-service-name.onrender.com/auth/oneid/callback
ONEID_REDIRECT_MOBILE=odo.app://auth/oneid/callback
APP_SCHEME=odo.app
ALLOWED_ORIGINS=http://localhost:8124,https://odo.uz,https://your-service-name.onrender.com
PORT=8787
```

⚠️ **Важно:** 
- Замените `ваш_секрет_здесь` на реальный `ONEID_CLIENT_SECRET`
- После первого деплоя получите URL и обновите `ONEID_REDIRECT_WEB` и `ALLOWED_ORIGINS`

### 2.4. Создание и проверка

1. Нажмите **"Create Web Service"**
2. Дождитесь завершения деплоя (2-3 минуты)
3. Проверьте health check: `https://your-service-name.onrender.com/health`
   - Должно вернуть: `{"ok":true}`

## Шаг 3: Настройка OneID в кабинете

В кабинете OneID добавьте Redirect URIs:
- `https://your-service-name.onrender.com/auth/oneid/callback`
- `odo.app://auth/oneid/callback`

## Шаг 4: Обновление Flutter приложения

После получения URL вашего сервиса на Render, обновите `lib/config/oneid_config.dart`:

```dart
static const String backendUrl = 'https://your-service-name.onrender.com';
```

## Шаг 5: Настройка Deep Links (для мобильных приложений)

### Android

Убедитесь, что в `android/app/src/main/AndroidManifest.xml` есть:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="odo.app" android:host="auth" />
</intent-filter>
```

### iOS

Убедитесь, что в `ios/Runner/Info.plist` есть:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>odo.app</string>
        </array>
    </dict>
</array>
```

## Проверка работы

1. **Health Check:**
   ```bash
   curl https://your-service-name.onrender.com/health
   ```
   Ожидаемый ответ: `{"ok":true}`

2. **Тест в приложении:**
   - Запустите Flutter приложение
   - Перейдите на экран авторизации
   - Нажмите "Войти через OneID"
   - Должен открыться браузер с формой OneID
   - После авторизации должно произойти перенаправление обратно в приложение

## Troubleshooting

### Backend не отвечает
- Проверьте логи в Render Dashboard
- Убедитесь, что все environment variables установлены
- Проверьте, что `ONEID_CLIENT_SECRET` правильный

### CORS ошибки
- Проверьте `ALLOWED_ORIGINS` в environment variables
- Убедитесь, что домен вашего Flutter приложения добавлен

### Deep link не работает
- Проверьте, что `redirectUri` в конфигурации совпадает с настройками в OneID
- Для Android: проверьте `AndroidManifest.xml`
- Для iOS: проверьте `Info.plist`

### OneID возвращает ошибку
- Проверьте, что все Redirect URIs правильно настроены в OneID
- Убедитесь, что `ONEID_CLIENT_ID` и `ONEID_CLIENT_SECRET` правильные
- Проверьте логи в Render Dashboard для деталей ошибки

