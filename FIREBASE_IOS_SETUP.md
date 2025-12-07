# 🔥 Firebase iOS Setup

## ✅ Текущая конфигурация

Firebase уже настроен через **FlutterFire** (CocoaPods), что является рекомендуемым способом для Flutter проектов.

### Что уже настроено:

1. **FlutterFire зависимости** (в `pubspec.yaml`):
   - `firebase_core`
   - `firebase_auth`
   - `cloud_firestore`
   - `firebase_storage`
   - `firebase_messaging`
   - `firebase_analytics`

2. **CocoaPods** (в `ios/Podfile`):
   - Автоматически управляется через `flutter_install_all_ios_pods`
   - Все Firebase зависимости устанавливаются автоматически

3. **Инициализация**:
   - Dart: `FirebaseConfig.initialize()` в `main.dart`
   - Native: `FirebaseApp.configure()` в `AppDelegate.swift`

4. **Конфигурационные файлы**:
   - `ios/Runner/GoogleService-Info.plist` ✅
   - `lib/firebase_options.dart` ✅

## 📝 Важно: Swift Package Manager vs CocoaPods

### ❌ НЕ используйте Swift Package Manager для Firebase в Flutter проектах

**Причины:**
- FlutterFire управляет зависимостями через CocoaPods
- Двойная установка может вызвать конфликты
- Flutter плагины требуют CocoaPods

### ✅ Используйте CocoaPods (уже настроено)

Все зависимости управляются автоматически через:
```bash
cd ios
pod install
```

## 🔧 Обновление зависимостей

Если нужно обновить Firebase зависимости:

```bash
# 1. Обновить Flutter зависимости
flutter pub get

# 2. Обновить iOS зависимости
cd ios
pod install
cd ..
```

## 🚀 Инициализация Firebase

### В Dart коде (уже настроено):
```dart
// lib/main.dart
await FirebaseConfig.initialize();
```

### В нативном коде (AppDelegate.swift):
```swift
import FirebaseCore

override func application(...) -> Bool {
    FirebaseApp.configure()
    // ...
}
```

## 📱 Проверка работы

1. **Запустите приложение**:
   ```bash
   flutter run -d ios
   ```

2. **Проверьте логи**:
   - Должно быть: `✅ Firebase инициализирован успешно!`

3. **Проверьте функции**:
   - Аутентификация работает
   - Firestore читает/пишет данные
   - Push-уведомления работают
   - Analytics логирует события

## 🐛 Решение проблем

### Ошибка: "Firebase not configured"
- Убедитесь, что `GoogleService-Info.plist` в `ios/Runner/`
- Проверьте, что `FirebaseApp.configure()` вызывается в `AppDelegate`

### Ошибка: "Pod not found"
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Ошибка: "Build failed"
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
```

## 📚 Дополнительные ресурсы

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [CocoaPods Guide](https://guides.cocoapods.org/)
