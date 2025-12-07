# ❌ Это неправильно!

## ❌ Что вы сделали:

В диалоге **"Build Location"** вы указали:
- **Products:** `/Users/dulatea/XcodeDerivedData` ❌
- **Intermediates:** `Build/Intermediates.noindex`

Это **НЕ правильно**, потому что:
1. Вы все еще в поднастройке "Build Location"
2. Поле "Products" должно содержать **относительный путь**, а не полный
3. Это не изменит основной путь DerivedData

## ✅ Что нужно сделать:

### Шаг 1: Закройте диалог "Build Location"

1. **Нажмите "Done"** в диалоге "Build Location"
2. Вы вернетесь в основное окно **"Locations"**

### Шаг 2: Найдите раздел "Derived Data"

В основном окне **"Locations"** найдите раздел **"Derived Data"** (он должен быть в верхней части, выше "Build Location").

Вы увидите что-то вроде:
```
Derived Data
/Users/dulatea/Library/Developer/Xcode/DerivedData
[Default] [Build Location...]
```

### Шаг 3: Измените основной путь

1. **Кликните на путь** `/Users/dulatea/Library/Developer/Xcode/DerivedData`
   - Или нажмите на **"Default"** рядом с путем
2. В открывшемся меню выберите **"Custom"**
3. Введите новый путь:
   ```
   /Users/dulatea/XcodeDerivedData
   ```
4. Нажмите **"Done"**

### Шаг 4: Проверьте

После изменения должно быть:
```
Derived Data
/Users/dulatea/XcodeDerivedData
[Custom] [Build Location...]
```

**НЕ должно быть:**
```
Derived Data
/Users/dulatea/Library/Developer/Xcode/DerivedData  ❌
```

### Шаг 5: Закройте и перезапустите Xcode

1. Закройте окно **"Locations"**
2. **Полностью закройте Xcode** (`Cmd + Q`)
3. Откройте проект заново
4. **Product → Clean Build Folder** (`Shift + Cmd + K`)
5. **Product → Build** (`Cmd + B`)

## ⚠️ Важно:

- **"Derived Data"** - это основной путь (его нужно изменить)
- **"Build Location"** - это поднастройка (не трогайте ее)
- После изменения **обязательно перезапустите Xcode**

