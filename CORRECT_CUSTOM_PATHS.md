# ✅ Правильные пути для Custom Build Location

## 📋 Настройка "Custom" в Build Location

Если вы выбрали **"Custom"** в настройках Build Location, есть два варианта:

### Вариант 1: "Relative to Derived Data" (РЕКОМЕНДУЕТСЯ)

Если выбрано **"Relative to Derived Data"**:

**Products:**
```
Build/Products
```

**Intermediates:**
```
Build/Intermediates.noindex
```

Это **относительные пути** от DerivedData (`/Users/dulatea/XcodeDerivedData`).

### Вариант 2: Абсолютные пути

Если вы хотите использовать **абсолютные пути** (не рекомендуется):

**Products:**
```
/Users/dulatea/XcodeDerivedData/Build/Products
```

**Intermediates:**
```
/Users/dulatea/XcodeDerivedData/Build/Intermediates.noindex
```

## ⚠️ Важно:

**НЕ должно быть:**
- `/Users/dulatea/uzbekservice_app/ios/   /Users/dulatea/XcodeDerivedData/...` ❌ (два пути склеены)
- `~/XcodeDerivedData/...` ❌ (тильда не работает)
- `XcodeDerivedData/...` ❌ (относительный путь без "Relative to Derived Data")

## 💡 Рекомендация:

**Лучше всего использовать "Unique"** вместо "Custom":

1. В диалоге "Build Location" выберите **"Unique"**
2. Нажмите "Done"

Это автоматически настроит правильные пути и избежит проблем.

## ✅ Правильная настройка:

```
Build Location: Custom
☑ Relative to Derived Data

Products: Build/Products
Intermediates: Build/Intermediates.noindex
```

Или просто:

```
Build Location: Unique
```

