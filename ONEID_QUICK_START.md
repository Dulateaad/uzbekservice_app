# 🚀 OneID Quick Start - 5 минут до запуска

## ✅ Что уже готово

1. ✅ OneID конфигурация (`lib/config/oneid_config.dart`)
2. ✅ OneID Service (`lib/services/oneid_service.dart`)
3. ✅ Экран входа (`lib/screens/auth/specialist_oneid_login_screen.dart`)
4. ✅ Deep Link провайдер (`lib/providers/oneid_provider.dart`)
5. ✅ Firestore интеграция (методы для работы с ПИНФЛ)

## 📝 Что нужно сделать (3 шага)

### Шаг 1: Обновите URL бэкенда (30 сек)

Откройте `lib/config/oneid_config.dart` и замените URL:

```dart
static const String backendUrl = 'https://ВАШ-БЭКЕНД.onrender.com';
```

**Узнать URL бэкенда:**
1. Откройте https://dashboard.render.com/
2. Найдите сервис `odo-oneid-backend`
3. Скопируйте URL (например: `https://odo-oneid-backend-xyz.onrender.com`)

### Шаг 2: Установите зависимости (1 мин)

```bash
cd /Users/dulat/uzbekservice_app
flutter pub get
```

### Шаг 3: Добавьте маршрут (2 мин)

Откройте `lib/utils/app_router.dart` и добавьте:

```dart
GoRoute(
  path: '/specialist-oneid-login',
  name: 'specialist-oneid-login',
  builder: (context, state) => const SpecialistOneIdLoginScreen(),
),
```

Не забудьте добавить import:

```dart
import '../screens/auth/specialist_oneid_login_screen.dart';
```

## 🎨 Добавьте кнопку на экран авторизации

Найдите экран выбора роли (например, `lib/screens/auth/role_selection_screen.dart`) и добавьте:

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0066CC),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: () {
    context.go('/specialist-oneid-login');
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.fingerprint, size: 24),
      const SizedBox(width: 12),
      const Text(
        'Я специалист (OneID)',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ],
  ),
),
```

## ▶️ Запуск

```bash
flutter run -d chrome
```

Или для мобильного тестирования:

```bash
flutter run -d ios
# или
flutter run -d android
```

## 🧪 Тестирование

1. Откройте приложение
2. Нажмите "Я специалист (OneID)"
3. Нажмите "Войти через OneID"
4. Откроется браузер с OneID
5. Авторизуйтесь через OneID
6. Вернётесь в приложение автоматически

## ⚠️ Важно для production

### Android Deep Linking

Создайте файл `android/app/src/main/AndroidManifest.xml` (если нет):

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="odouzapp" android:host="oneid" />
</intent-filter>
```

### iOS Deep Linking

Обновите `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>odouzapp</string>
        </array>
    </dict>
</array>
```

## 🆘 Проблемы?

### "Не удалось открыть OneID"
- Проверьте URL бэкенда
- Проверьте что бэкенд работает

### "Код авторизации не получен"
- Проверьте deep linking настройки
- Для web используйте redirect на http://localhost

### "Ошибка сохранения в Firestore"
- Проверьте что Firebase инициализирован
- Проверьте права доступа Firestore

## 📚 Подробная документация

См. `ONEID_INTEGRATION_GUIDE.md` для полной документации.

---

**Время интеграции:** ~5 минут  
**Сложность:** ⭐⭐ (Легко)

