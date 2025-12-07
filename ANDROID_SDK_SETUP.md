# 📱 Установка Android SDK - Инструкция

## ❌ Проблема
Android SDK Command Line Tools требует Java 17+, а текущая версия Java слишком старая.

## ✅ Решение: Установить Android Studio (РЕКОМЕНДУЕТСЯ)

**Android Studio** - это самый простой и надежный способ. Он включает:
- ✅ Android SDK
- ✅ Java (правильная версия)
- ✅ Эмулятор для тестирования
- ✅ Все необходимые инструменты

### Шаги:

1. **Скачать Android Studio:**
   ```
   https://developer.android.com/studio
   ```

2. **Установить:**
   - Откройте скачанный `.dmg` файл
   - Перетащите Android Studio в Applications
   - Запустите из Applications

3. **При первом запуске:**
   - Выберите "Standard" установку
   - Android SDK установится автоматически в `~/Library/Android/sdk`
   - Все необходимые компоненты будут установлены

4. **Проверить:**
   ```bash
   flutter doctor
   ```

## 🔄 Альтернатива: Установить Java 17+ вручную

Если хотите использовать только SDK без Android Studio:

1. **Установить Java 17+ через Homebrew:**
   ```bash
   brew install openjdk@17
   sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
   ```

2. **Проверить версию:**
   ```bash
   java -version
   # Должно показать: openjdk version "17.x.x"
   ```

3. **Продолжить установку SDK:**
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   
   yes | sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

4. **Добавить в ~/.zshrc:**
   ```bash
   echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
   source ~/.zshrc
   ```

## 💡 Рекомендация

**Используйте Android Studio** - это займет 5-10 минут, но вы получите:
- ✅ Все необходимое из коробки
- ✅ Правильную версию Java
- ✅ Эмулятор для тестирования
- ✅ Меньше проблем с настройкой

## 🚀 После установки

```bash
# Проверить
flutter doctor

# Собрать AAB
./build_release.sh
```

