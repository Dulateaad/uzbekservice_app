# Инструкция по переносу проекта на другой MacBook

## Способ 1: Через Git (Рекомендуется) ✅

### На текущем MacBook:

1. **Создать Git репозиторий** (уже сделано):
   ```bash
   cd /Users/dulat/uzbekservice_app
   git init
   ```

2. **Добавить все файлы**:
   ```bash
   git add .
   git commit -m "Initial commit: uzbekservice_app with Supabase"
   ```

3. **Создать репозиторий на GitHub/GitLab**:
   - Зайдите на https://github.com (или GitLab)
   - Создайте новый репозиторий (например, `uzbekservice_app`)
   - НЕ добавляйте README, .gitignore или лицензию

4. **Подключить удаленный репозиторий**:
   ```bash
   git remote add origin https://github.com/ВАШ_USERNAME/uzbekservice_app.git
   git branch -M main
   git push -u origin main
   ```

### На новом MacBook:

1. **Установить Flutter**:
   ```bash
   # Скачать Flutter с https://flutter.dev/docs/get-started/install/macos
   # Или использовать Homebrew:
   brew install --cask flutter
   ```

2. **Проверить установку**:
   ```bash
   flutter doctor
   ```

3. **Клонировать проект**:
   ```bash
   cd ~
   git clone https://github.com/ВАШ_USERNAME/uzbekservice_app.git
   cd uzbekservice_app
   ```

4. **Установить зависимости**:
   ```bash
   flutter pub get
   ```

5. **Настроить Supabase ключи**:
   - Откройте `lib/config/supabase_config.dart`
   - Убедитесь, что там правильные ключи Supabase
   - Или создайте `.env` файл (если настроена поддержка)

6. **Запустить проект**:
   ```bash
   flutter run -d chrome
   # или
   flutter run -d macos
   ```

---

## Способ 2: Через внешний диск/облако

### На текущем MacBook:

1. **Архивировать проект** (исключая ненужные файлы):
   ```bash
   cd /Users/dulat
   tar -czf uzbekservice_app_backup.tar.gz \
     --exclude='uzbekservice_app/build' \
     --exclude='uzbekservice_app/.dart_tool' \
     --exclude='uzbekservice_app/.flutter-plugins' \
     --exclude='uzbekservice_app/.flutter-plugins-dependencies' \
     --exclude='uzbekservice_app/.packages' \
     --exclude='uzbekservice_app/.pub' \
     --exclude='uzbekservice_app/.pub-cache' \
     --exclude='uzbekservice_app/flutter' \
     uzbekservice_app
   ```

2. **Скопировать архив**:
   - На внешний диск, или
   - В облако (Google Drive, Dropbox, iCloud), или
   - Через AirDrop на новый MacBook

### На новом MacBook:

1. **Установить Flutter** (см. выше)

2. **Распаковать проект**:
   ```bash
   cd ~
   tar -xzf uzbekservice_app_backup.tar.gz
   cd uzbekservice_app
   ```

3. **Установить зависимости**:
   ```bash
   flutter pub get
   ```

4. **Настроить и запустить** (см. выше)

---

## Способ 3: Через rsync (если оба MacBook в одной сети)

### На новом MacBook:

```bash
# Установить Flutter (см. выше)

# Синхронизировать проект
rsync -avz --exclude='build' \
           --exclude='.dart_tool' \
           --exclude='.flutter-plugins' \
           --exclude='flutter' \
           dulat@IP_СТАРОГО_МАКБУКА:/Users/dulat/uzbekservice_app/ \
           ~/uzbekservice_app/

cd ~/uzbekservice_app
flutter pub get
flutter run -d chrome
```

---

## Важные файлы для проверки после переноса:

1. **`lib/config/supabase_config.dart`** - ключи Supabase
2. **`pubspec.yaml`** - зависимости проекта
3. **`.gitignore`** - игнорируемые файлы
4. **`supabase_schema.sql`** - схема базы данных

## Настройка на новом MacBook:

### 1. Flutter SDK:
```bash
flutter doctor
# Если нужно добавить в PATH:
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Xcode (для iOS разработки):
```bash
xcode-select --install
sudo xcodebuild -license accept
```

### 3. Android Studio (для Android разработки):
- Скачать с https://developer.android.com/studio
- Установить Android SDK

### 4. Проверка зависимостей:
```bash
cd ~/uzbekservice_app
flutter pub get
flutter doctor
```

## Возможные проблемы:

### Проблема: "No pubspec.yaml file found"
**Решение**: Убедитесь, что вы в правильной директории проекта

### Проблема: "Command not found: flutter"
**Решение**: Добавьте Flutter в PATH или используйте полный путь

### Проблема: Ошибки компиляции
**Решение**: 
```bash
flutter clean
flutter pub get
flutter run
```

### Проблема: Supabase не подключается
**Решение**: Проверьте ключи в `lib/config/supabase_config.dart`

## Рекомендации:

1. ✅ Используйте Git для версионирования и синхронизации
2. ✅ Храните секретные ключи в `.env` (не коммитьте в Git)
3. ✅ Регулярно делайте коммиты и push
4. ✅ Используйте `.gitignore` для исключения ненужных файлов

## Быстрая команда для переноса через Git:

```bash
# На старом MacBook:
cd /Users/dulat/uzbekservice_app
git add .
git commit -m "Transfer to new MacBook"
git remote add origin YOUR_REPO_URL
git push -u origin main

# На новом MacBook:
git clone YOUR_REPO_URL
cd uzbekservice_app
flutter pub get
flutter run -d chrome
```

