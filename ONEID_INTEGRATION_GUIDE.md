# 🔐 Руководство по интеграции OneID для специалистов

## 📋 Что было сделано

### 1. Создана конфигурация OneID
- **Файл:** `lib/config/oneid_config.dart`
- **URL бэкенда:** `https://odo-oneid-backend.onrender.com`
- **Redirect URI:** `odouzapp://oneid/callback`

### 2. Создан OneID Service
- **Файл:** `lib/services/oneid_service.dart`
- Методы:
  - `startAuthFlow()` - начало OAuth2 авторизации
  - `handleCallback()` - обработка callback от OneID
  - `getUserInfo()` - получение данных пользователя

### 3. Создан экран входа для специалистов
- **Файл:** `lib/screens/auth/specialist_oneid_login_screen.dart`
- Красивый UI с кнопкой OneID
- Обработка ошибок
- Интеграция с Firestore

### 4. Обновлён FirestoreService
- Добавлен метод `getUsersByPin()` - поиск по ПИНФЛ
- Обновлён метод `createUser()` - возвращает `FirestoreUser`

### 5. Создан провайдер для Deep Links
- **Файл:** `lib/providers/oneid_provider.dart`
- Автоматическая обработка callback от OneID

## ⚙️ Настройка проекта

### Шаг 1: Обновите URL бэкенда

В файле `lib/config/oneid_config.dart` замените URL на актуальный:

```dart
static const String backendUrl = 'https://ваш-бэкенд.onrender.com';
```

### Шаг 2: Установите зависимости

```bash
cd /Users/dulat/uzbekservice_app
flutter pub get
```

### Шаг 3: Настройте Deep Linking для Android

Создайте/обновите файл `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity
            android:name=".MainActivity"
            android:exported="true">
            
            <!-- Существующие intent-filters -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            
            <!-- OneID Deep Link -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="odouzapp" android:host="oneid" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### Шаг 4: Настройте Deep Linking для iOS

Обновите файл `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Существующие настройки -->
    
    <!-- OneID Deep Link -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>uz.odo.app</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>odouzapp</string>
            </array>
        </dict>
    </array>
</dict>
```

### Шаг 5: Добавьте маршрут в GoRouter

Обновите файл `lib/utils/app_router.dart`:

```dart
GoRoute(
  path: '/specialist-oneid-login',
  name: 'specialist-oneid-login',
  builder: (context, state) => const SpecialistOneIdLoginScreen(),
),
```

### Шаг 6: Инициализируйте Deep Link слушатель

Обновите `lib/main.dart`:

```dart
import 'providers/oneid_provider.dart';

class UzbekistanServiceApp extends ConsumerStatefulWidget {
  const UzbekistanServiceApp({super.key});

  @override
  ConsumerState<UzbekistanServiceApp> createState() => _UzbekistanServiceAppState();
}

class _UzbekistanServiceAppState extends ConsumerState<UzbekistanServiceApp> {
  OneIdDeepLinkListener? _deepLinkListener;

  @override
  void initState() {
    super.initState();
    // Инициализируем слушатель deep links
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkListener = OneIdDeepLinkListener(ref);
      _deepLinkListener?.init();
    });
  }

  @override
  void dispose() {
    _deepLinkListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем результат OneID авторизации
    ref.listen<OneIdAuthResult?>(oneIdAuthResultProvider, (previous, next) {
      if (next != null && next.success && next.user != null) {
        // Успешная авторизация - переходим на обработку
        _handleOneIdSuccess(next);
      }
    });

    return MaterialApp.router(
      // ... остальной код
    );
  }

  Future<void> _handleOneIdSuccess(OneIdAuthResult result) async {
    // Найти экран SpecialistOneIdLoginScreen и вызвать handleOneIdCallback
    // Или обработать здесь напрямую
  }
}
```

## 🚀 Использование

### Для клиентов (SMS вход)
Существующий flow остаётся без изменений.

### Для специалистов (OneID вход)

1. На экране выбора роли добавьте кнопку "Я специалист"
2. При нажатии переходите на `/specialist-oneid-login`
3. Пользователь нажимает "Войти через OneID"
4. Открывается браузер с OneID авторизацией
5. После успешной авторизации OneID перенаправляет на `odouzapp://oneid/callback?code=...`
6. Приложение обрабатывает callback и создаёт/обновляет пользователя в Firestore

## 🔧 Настройка бэкенда

Убедитесь, что ваш бэкенд на Render имеет следующие endpoints:

### 1. GET /api/oneid/login
**Query params:**
- `redirect_uri` - URI для возврата (`odouzapp://oneid/callback`)
- `state` - CSRF токен

**Ответ:** Redirect на OneID с параметрами OAuth2

### 2. POST /api/oneid/callback
**Body:**
```json
{
  "code": "authorization_code_from_oneid",
  "redirect_uri": "odouzapp://oneid/callback"
}
```

**Ответ:**
```json
{
  "access_token": "jwt_token",
  "refresh_token": "refresh_token",
  "user": {
    "sub": "user_id",
    "pin": "12345678901234",
    "full_name": "Ivanov Ivan",
    "full_name_cyrillic": "Иванов Иван",
    "birth_date": "1990-01-01",
    "email": "user@example.com",
    "phone": "+998901234567"
  }
}
```

### 3. GET /api/oneid/user
**Headers:**
```
Authorization: Bearer {access_token}
```

**Ответ:** То же самое что `user` в `/api/oneid/callback`

## 🧪 Тестирование

### 1. Проверка deep linking

```bash
# Android
adb shell am start -W -a android.intent.action.VIEW -d "odouzapp://oneid/callback?code=test123"

# iOS
xcrun simctl openurl booted "odouzapp://oneid/callback?code=test123"
```

### 2. Проверка бэкенда

```bash
# Проверка login endpoint
curl "https://ваш-бэкенд.onrender.com/api/oneid/login?redirect_uri=odouzapp://oneid/callback&state=test"

# Проверка callback endpoint
curl -X POST https://ваш-бэкенд.onrender.com/api/oneid/callback \
  -H "Content-Type: application/json" \
  -d '{"code":"test_code","redirect_uri":"odouzapp://oneid/callback"}'
```

## 📱 Пример использования в UI

```dart
// На главном экране авторизации добавьте кнопку для специалистов
ElevatedButton(
  onPressed: () {
    context.go('/specialist-oneid-login');
  },
  child: const Text('Я специалист'),
),
```

## ❓ Troubleshooting

### Проблема: Deep link не работает
**Решение:** Убедитесь, что:
1. Добавлены intent-filters в AndroidManifest.xml
2. Добавлены CFBundleURLSchemes в Info.plist
3. Установлен пакет `uni_links`

### Проблема: Ошибка "Не удалось получить токен"
**Решение:** Проверьте:
1. URL бэкенда в `oneid_config.dart`
2. Бэкенд работает и доступен
3. Правильный redirect_uri

### Проблема: Пользователь не сохраняется в Firestore
**Решение:** Проверьте:
1. Firebase инициализирован
2. Права доступа к Firestore
3. Поле `oneIdPin` добавлено в модель `FirestoreUser`

## 🔄 Обновление модели FirestoreUser

Если поле `oneIdPin` отсутствует в модели, добавьте его:

```dart
class FirestoreUser {
  // ... существующие поля
  final String? oneIdPin; // ПИНФЛ из OneID

  FirestoreUser({
    // ... существующие параметры
    this.oneIdPin,
  });

  Map<String, dynamic> toMap() {
    return {
      // ... существующие поля
      'oneIdPin': oneIdPin,
    };
  }

  factory FirestoreUser.fromMap(Map<String, dynamic> map) {
    return FirestoreUser(
      // ... существующие поля
      oneIdPin: map['oneIdPin'],
    );
  }
}
```

## 📚 Дополнительные ресурсы

- [OneID Documentation](https://id.egov.uz/)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [uni_links package](https://pub.dev/packages/uni_links)
- [OAuth2 PKCE Flow](https://oauth.net/2/pkce/)

---

**Автор:** ODO.UZ Team  
**Дата:** 2025  
**Версия:** 1.0

