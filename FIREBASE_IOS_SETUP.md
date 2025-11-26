# 🔥 Настройка Firebase для iOS

## 📋 Пошаговая инструкция

### 1. Добавление iOS приложения в Firebase
1. Откройте [Firebase Console](https://console.firebase.google.com)
2. Выберите проект `odo-uz-app`
3. Нажмите **Add app** → **iOS**
4. Заполните:
   - **iOS bundle ID**: `com.yourcompany.odo_uz_app`
   - **App nickname**: ODO.UZ iOS
   - **App Store ID**: (оставьте пустым пока)

### 2. Скачивание GoogleService-Info.plist
1. Скачайте файл `GoogleService-Info.plist`
2. Перетащите его в Xcode проект:
   - Откройте `ios/Runner.xcworkspace`
   - Перетащите файл в папку `Runner`
   - Убедитесь, что файл добавлен в target `Runner`

### 3. Настройка Firebase SDK
Файл уже настроен в `lib/config/firebase_config.dart`

### 4. Настройка Push Notifications (опционально)
1. В Firebase Console → **Project Settings** → **Cloud Messaging**
2. Загрузите сертификат APNs:
   - Создайте сертификат в Apple Developer Portal
   - Загрузите в Firebase Console

### 5. Настройка App Transport Security
Добавьте в `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 6. Тестирование
```bash
# Сборка для симулятора
flutter run -d ios

# Сборка для устройства
flutter run -d ios --release
```

## 🔧 Дополнительные настройки

### Analytics
Firebase Analytics уже включен в конфигурации.

### Crashlytics
Для включения Crashlytics добавьте в `ios/Runner/AppDelegate.swift`:
```swift
import FirebaseCrashlytics

// В application:didFinishLaunchingWithOptions:
FirebaseApp.configure()
```

### Remote Config
Для использования Remote Config добавьте зависимость:
```yaml
dependencies:
  firebase_remote_config: ^4.3.8
```

## 🚨 Частые проблемы

### Ошибка "GoogleService-Info.plist not found"
- Убедитесь, что файл добавлен в Xcode проект
- Проверьте, что файл в правильной папке

### Ошибка сборки Firebase
- Обновите CocoaPods: `pod update`
- Очистите кэш: `flutter clean`

### Ошибка подключения к Firebase
- Проверьте Bundle ID в Firebase Console
- Убедитесь, что файл GoogleService-Info.plist актуальный

---

**Готово! Firebase настроен для iOS 🎉**
