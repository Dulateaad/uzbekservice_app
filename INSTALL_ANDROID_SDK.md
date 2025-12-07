# 📱 Установка Android SDK для сборки AAB

## ❌ Проблема
Cask `android-sdk` отключен в Homebrew (больше не поддерживается).

## ✅ Решение: Установить Android Studio

### Вариант 1: Android Studio (рекомендуется)

1. **Скачать Android Studio:**
   - Перейдите: https://developer.android.com/studio
   - Скачайте версию для macOS

2. **Установить:**
   ```bash
   # Если скачали .dmg файл
   open ~/Downloads/android-studio-*.dmg
   # Перетащите Android Studio в Applications
   ```

3. **Запустить и настроить:**
   - Откройте Android Studio из Applications
   - При первом запуске выберите "Standard" установку
   - Android SDK установится автоматически

4. **Проверить установку:**
   ```bash
   flutter doctor
   ```

### Вариант 2: Только SDK через командную строку

Если не хотите устанавливать полный Android Studio:

1. **Скачать Command Line Tools:**
   ```bash
   # Создать директорию для SDK
   mkdir -p ~/Library/Android/sdk
   
   # Скачать Command Line Tools
   cd ~/Library/Android/sdk
   curl -O https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip
   unzip commandlinetools-mac-11076708_latest.zip
   mkdir -p cmdline-tools/latest
   mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
   ```

2. **Установить SDK компоненты:**
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   
   # Установить необходимые компоненты
   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

3. **Добавить в ~/.zshrc:**
   ```bash
   echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
   source ~/.zshrc
   ```

## 🔍 Проверка после установки

```bash
# Проверить Flutter
flutter doctor

# Должно показать:
# [✓] Android toolchain - develop for Android devices
```

## 🚀 После установки SDK

```bash
# Собрать AAB
./build_release.sh
```

## 💡 Рекомендация

**Используйте Android Studio** - это проще и надежнее. Полная установка займет ~5-10 минут, но вы получите:
- ✅ Android SDK
- ✅ Эмулятор для тестирования
- ✅ Инструменты разработки
- ✅ Автоматическую настройку

