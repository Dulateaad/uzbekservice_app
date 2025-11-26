# Настройка GitHub репозитория

## Шаг 1: Создать репозиторий на GitHub

1. Зайдите на https://github.com
2. Нажмите кнопку **"+"** в правом верхнем углу → **"New repository"**
3. Заполните форму:
   - **Repository name**: `uzbekservice_app`
   - **Description** (опционально): `ODO.UZ - Платформа для соединения клиентов со специалистами`
   - **Visibility**: 
     - ✅ **Public** (если хотите открытый репозиторий)
     - ✅ **Private** (если хотите приватный репозиторий)
   - ❌ **НЕ** ставьте галочки на:
     - Add a README file
     - Add .gitignore
     - Choose a license
4. Нажмите **"Create repository"**

## Шаг 2: Скопировать URL репозитория

После создания репозитория GitHub покажет страницу с инструкциями. 

**URL будет выглядеть так:**
```
https://github.com/ВАШ_USERNAME/uzbekservice_app.git
```

**Или через SSH (если настроен):**
```
git@github.com:ВАШ_USERNAME/uzbekservice_app.git
```

## Шаг 3: Подключить репозиторий к проекту

Выполните эти команды в терминале:

```bash
cd /Users/dulat/uzbekservice_app

# Добавить удаленный репозиторий
git remote add origin https://github.com/ВАШ_USERNAME/uzbekservice_app.git

# Или если используете SSH:
# git remote add origin git@github.com:ВАШ_USERNAME/uzbekservice_app.git

# Проверить подключение
git remote -v
```

## Шаг 4: Загрузить код на GitHub

```bash
# Добавить все файлы
git add .

# Сделать первый коммит
git commit -m "Initial commit: uzbekservice_app with Supabase"

# Переименовать ветку в main (если нужно)
git branch -M main

# Загрузить на GitHub
git push -u origin main
```

## Примеры URL для разных случаев:

### Если ваш username: `dulat`
```
https://github.com/dulat/uzbekservice_app.git
```

### Если организация: `mycompany`
```
https://github.com/mycompany/uzbekservice_app.git
```

### Через SSH (если настроен ключ):
```
git@github.com:dulat/uzbekservice_app.git
```

## Проверка после подключения:

```bash
# Проверить удаленные репозитории
git remote -v

# Должно показать:
# origin  https://github.com/ВАШ_USERNAME/uzbekservice_app.git (fetch)
# origin  https://github.com/ВАШ_USERNAME/uzbekservice_app.git (push)
```

## Если нужно изменить URL:

```bash
# Удалить старый remote
git remote remove origin

# Добавить новый
git remote add origin НОВЫЙ_URL
```

## Быстрая команда (замените YOUR_USERNAME):

```bash
cd /Users/dulat/uzbekservice_app
git remote add origin https://github.com/YOUR_USERNAME/uzbekservice_app.git
git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main
```

