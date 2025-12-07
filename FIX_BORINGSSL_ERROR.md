# 🔧 Исправление ошибки BoringSSL-GRPC

## ❌ Ошибка:
```
unsupported option '-G' for target 'arm64-apple-ios12.0'
```

## ✅ Решение:

### Вариант 1: Обновить iOS Deployment Target (рекомендуется)

1. **В Xcode:**
   - Выберите проект **Runner** (синяя иконка)
   - Выберите target **Runner**
   - Вкладка **General**
   - **iOS Deployment Target**: измените на **13.0** или выше

2. **Или через Podfile:**
   - Откройте `ios/Podfile`
   - Убедитесь, что: `platform :ios, '13.0'`

### Вариант 2: Обновить CocoaPods зависимости

```bash
cd ~/uzbekservice_app/ios
pod deintegrate
pod install
cd ..
```

### Вариант 3: Обновить Xcode Command Line Tools

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Вариант 4: Очистить и пересобрать

```bash
cd ~/uzbekservice_app
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
```

## 📋 Пошаговая инструкция:

### Шаг 1: Проверьте iOS Deployment Target

1. В Xcode: **Runner** project → **Runner** target
2. Вкладка **General**
3. **iOS Deployment Target**: должно быть **13.0** или выше
4. Если меньше, измените на **13.0**

### Шаг 2: Обновите Podfile

1. Откройте `ios/Podfile`
2. Убедитесь: `platform :ios, '13.0'`
3. Если нет, измените

### Шаг 3: Переустановите зависимости

```bash
cd ~/uzbekservice_app/ios
pod deintegrate
pod install
cd ..
```

### Шаг 4: Очистите проект

1. В Xcode: **Product** → **Clean Build Folder** (Shift + Cmd + K)
2. Или: `flutter clean`

### Шаг 5: Попробуйте сборку

1. **Product** → **Build** (Cmd + B)
2. Дождитесь завершения

## 🔍 Проверка:

После исправления ошибки должны исчезнуть. Проверьте:
- Вкладка **Issues** (⚠️) - должно быть 0 ошибок
- Статус вверху: **"Build Succeeded"**

## 📱 После исправления:

1. **Product** → **Build** (Cmd + B) - проверка
2. **Product** → **Archive** - создание архива
3. **Organizer** → **Distribute App** - загрузка в TestFlight

