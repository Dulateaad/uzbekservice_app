# 🚀 Быстрый перенос проекта на другой MacBook

## Вариант 1: Через GitHub (5 минут) ⭐ Рекомендуется

### Шаг 1: На текущем MacBook

```bash
cd /Users/dulat/uzbekservice_app

# Запустить скрипт подготовки
./quick_transfer.sh

# Или вручную:
git add .
git commit -m "Initial commit: uzbekservice_app"
```

### Шаг 2: Создать репозиторий на GitHub

1. Зайдите на https://github.com
2. Нажмите "New repository"
3. Название: `uzbekservice_app`
4. НЕ добавляйте README, .gitignore, лицензию
5. Нажмите "Create repository"

### Шаг 3: Подключить и загрузить

```bash
git remote add origin https://github.com/ВАШ_USERNAME/uzbekservice_app.git
git branch -M main
git push -u origin main
```

### Шаг 4: На новом MacBook

```bash
# 1. Установить Flutter (если еще не установлен)
# Скачать с https://flutter.dev/docs/get-started/install/macos

# 2. Клонировать проект
git clone https://github.com/ВАШ_USERNAME/uzbekservice_app.git
cd uzbekservice_app

# 3. Установить зависимости
flutter pub get

# 4. Запустить
flutter run -d chrome
```

---

## Вариант 2: Через архив (без интернета)

### На текущем MacBook:

```bash
cd /Users/dulat
tar -czf uzbekservice_app.tar.gz \
  --exclude='uzbekservice_app/build' \
  --exclude='uzbekservice_app/.dart_tool' \
  --exclude='uzbekservice_app/.flutter-plugins' \
  --exclude='uzbekservice_app/flutter' \
  uzbekservice_app
```

### Скопировать архив:
- На внешний диск, или
- Через AirDrop на новый MacBook

### На новом MacBook:

```bash
# Распаковать
tar -xzf uzbekservice_app.tar.gz
cd uzbekservice_app

# Установить зависимости
flutter pub get

# Запустить
flutter run -d chrome
```

---

## ⚙️ Настройка на новом MacBook

### 1. Установить Flutter:

```bash
# Вариант A: Через Homebrew
brew install --cask flutter

# Вариант B: Вручную
# Скачать с https://flutter.dev/docs/get-started/install/macos
# Распаковать и добавить в PATH
```

### 2. Проверить установку:

```bash
flutter doctor
```

### 3. Установить зависимости проекта:

```bash
cd ~/uzbekservice_app  # или путь к проекту
flutter pub get
```

### 4. Проверить ключи Supabase:

Откройте `lib/config/supabase_config.dart` и убедитесь, что там правильные ключи:
- `supabaseUrl`: `https://rxouorcmwrgrhkrunbfi.supabase.co`
- `supabaseAnonKey`: ваш anon key

---

## ✅ Проверка после переноса

```bash
# Проверить, что все файлы на месте
ls -la lib/

# Проверить зависимости
flutter pub get

# Попробовать запустить
flutter run -d chrome
```

---

## 🔧 Решение проблем

### "Command not found: flutter"
```bash
# Добавить Flutter в PATH
export PATH="$PATH:/path/to/flutter/bin"
# Или использовать полный путь
/path/to/flutter/bin/flutter run
```

### "No pubspec.yaml file found"
```bash
# Убедитесь, что вы в правильной директории
cd ~/uzbekservice_app
pwd  # Должно показать путь к проекту
```

### Ошибки компиляции
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📝 Важные файлы

После переноса проверьте:
- ✅ `lib/config/supabase_config.dart` - ключи Supabase
- ✅ `pubspec.yaml` - зависимости
- ✅ `supabase_schema.sql` - схема базы данных

---

## 💡 Советы

1. **Используйте Git** - это самый надежный способ синхронизации
2. **Делайте коммиты регулярно** - это поможет отслеживать изменения
3. **Не коммитьте секретные ключи** - используйте `.env` файлы
4. **Используйте `.gitignore`** - он уже настроен в проекте

---

## 📞 Нужна помощь?

Смотрите подробную инструкцию: `TRANSFER_TO_NEW_MAC.md`

