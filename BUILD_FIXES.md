# 🔧 Исправления в build.gradle.kts

## ✅ Исправленные ошибки:

1. **Импорты Java классов:**
   - Добавлены: `import java.util.Properties`
   - Добавлены: `import java.io.FileInputStream`
   - Теперь используются: `Properties()` и `FileInputStream()` вместо полных путей

2. **Kotlin JVM Target:**
   - Изменено с: `jvmTarget = JavaVersion.VERSION_17.toString()`
   - На: `jvmTarget = "17"`
   - Убрано предупреждение о deprecated синтаксисе

3. **Приведения типов:**
   - Добавлены безопасные приведения: `as String? ?: ""`
   - Исправлен `let` блок для `storeFile`

## 📝 Текущий синтаксис:

```kotlin
import java.util.Properties
import java.io.FileInputStream

// ...

val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

// ...

kotlinOptions {
    jvmTarget = "17"
}

// ...

signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
            keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
            val storeFileValue = keystoreProperties["storeFile"] as String?
            storeFile = storeFileValue?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String? ?: ""
        }
    }
}
```

## 🚀 Сборка:

```bash
flutter build appbundle --release
```

Готовый AAB будет в: `build/app/outputs/bundle/release/app-release.aab`

