# Установка и запуск Uzbekistan Service App

## Требования

- Flutter SDK 3.0.0 или выше
- Dart SDK 3.0.0 или выше
- Android Studio / Xcode для эмуляторов
- Git

## Установка Flutter

### macOS
```bash
# Скачайте Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip

# Распакуйте архив
unzip flutter_macos_3.16.0-stable.zip

# Добавьте Flutter в PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Добавьте в ~/.zshrc или ~/.bash_profile
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Windows
1. Скачайте Flutter SDK с https://flutter.dev/docs/get-started/install/windows
2. Распакуйте в C:\flutter
3. Добавьте C:\flutter\bin в PATH

### Linux
```bash
# Скачайте Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz

# Распакуйте архив
tar xf flutter_linux_3.16.0-stable.tar.xz

# Добавьте Flutter в PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

## Установка зависимостей

```bash
# Перейдите в директорию проекта
cd uzbekservice_app

# Установите зависимости
flutter pub get

# Генерируйте код для Hive
flutter packages pub run build_runner build
```

## Настройка Firebase

1. Создайте проект в Firebase Console
2. Добавьте Android/iOS приложение
3. Скачайте конфигурационные файлы:
   - `google-services.json` для Android (в `android/app/`)
   - `GoogleService-Info.plist` для iOS (в `ios/Runner/`)

## Настройка API

Создайте файл `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-api-domain.com/api/v1';
  static const String devBaseUrl = 'http://localhost:3000/api/v1';
}
```

## Запуск приложения

### Для разработки
```bash
# Запуск на Android
flutter run

# Запуск на iOS
flutter run -d ios

# Запуск на конкретном устройстве
flutter devices
flutter run -d <device-id>
```

### Для релиза
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Структура проекта

```
lib/
├── constants/          # Константы приложения
│   └── app_constants.dart
├── models/             # Модели данных
│   ├── user_model.dart
│   ├── specialist_model.dart
│   ├── order_model.dart
│   └── review_model.dart
├── providers/          # Провайдеры состояния
│   ├── auth_provider.dart
│   ├── specialist_provider.dart
│   └── order_provider.dart
├── screens/            # Экраны приложения
│   ├── auth/           # Аутентификация
│   ├── home/           # Главные экраны
│   ├── specialist/     # Специалисты
│   ├── order/          # Заказы
│   └── profile/        # Профиль
├── services/           # Сервисы
│   ├── api_service.dart
│   └── auth_service.dart
├── utils/              # Утилиты
│   └── app_router.dart
├── widgets/            # Переиспользуемые виджеты
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── category_card.dart
│   ├── specialist_card.dart
│   └── search_bar_widget.dart
└── main.dart           # Точка входа
```

## Возможные проблемы

### Ошибка "Flutter not found"
Убедитесь, что Flutter добавлен в PATH:
```bash
flutter doctor
```

### Ошибка сборки
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Проблемы с Firebase
1. Проверьте конфигурационные файлы
2. Убедитесь, что Firebase проект настроен правильно
3. Проверьте правила безопасности Firebase

### Проблемы с эмулятором
```bash
# Android
flutter emulators --launch <emulator-id>

# iOS (только на macOS)
open -a Simulator
```

## Дополнительные команды

```bash
# Анализ кода
flutter analyze

# Тесты
flutter test

# Форматирование кода
dart format .

# Проверка зависимостей
flutter pub deps
```
