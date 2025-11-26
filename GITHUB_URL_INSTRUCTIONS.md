# 📝 URL для GitHub репозитория

## Формат URL:

После создания репозитория на GitHub, URL будет выглядеть так:

```
https://github.com/ВАШ_USERNAME/uzbekservice_app.git
```

## Примеры:

### Если ваш GitHub username: `dulat`
```
https://github.com/dulat/uzbekservice_app.git
```

### Если ваш GitHub username: `johnsmith`
```
https://github.com/johnsmith/uzbekservice_app.git
```

### Если используете организацию: `mycompany`
```
https://github.com/mycompany/uzbekservice_app.git
```

## Где найти URL:

1. **После создания репозитория** на GitHub вы увидите страницу с инструкциями
2. **Или зайдите в репозиторий** → нажмите зеленую кнопку **"Code"** → скопируйте HTTPS URL

## После получения URL выполните:

```bash
cd /Users/dulat/uzbekservice_app

# Подключить репозиторий (замените YOUR_USERNAME на ваш username)
git remote add origin https://github.com/YOUR_USERNAME/uzbekservice_app.git

# Проверить
git remote -v

# Добавить файлы
git add .

# Сделать коммит
git commit -m "Initial commit: uzbekservice_app"

# Загрузить на GitHub
git branch -M main
git push -u origin main
```

## Если используете SSH (рекомендуется для безопасности):

Если у вас настроен SSH ключ на GitHub, используйте:

```
git@github.com:YOUR_USERNAME/uzbekservice_app.git
```

## Быстрая команда (скопируйте и замените YOUR_USERNAME):

```bash
cd /Users/dulat/uzbekservice_app && \
git remote add origin https://github.com/YOUR_USERNAME/uzbekservice_app.git && \
git add . && \
git commit -m "Initial commit" && \
git branch -M main && \
git push -u origin main
```

---

**💡 Совет:** Если вы еще не создали репозиторий на GitHub:
1. Зайдите на https://github.com/new
2. Название: `uzbekservice_app`
3. НЕ добавляйте README, .gitignore, лицензию
4. Нажмите "Create repository"
5. Скопируйте URL с этой страницы

