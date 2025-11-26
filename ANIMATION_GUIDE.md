# 🎨 Руководство по анимациям в ODO.UZ

## Обзор

В приложении ODO.UZ реализованы различные типы анимаций для улучшения пользовательского опыта. Все анимации следуют принципам Material Design и обеспечивают плавные переходы между экранами.

## 🚀 Splash Screen Анимации

### 1. AnimatedSplashScreen
**Файл:** `lib/screens/splash/animated_splash_screen.dart`

**Особенности:**
- Множественные анимации (масштабирование, поворот, прозрачность)
- Анимированные частицы на фоне
- Градиентный фон с анимацией
- Последовательное выполнение анимаций

**Использование:**
```dart
// В app_router.dart
GoRoute(
  path: '/splash',
  builder: (context, state) => const AnimatedSplashScreen(),
),
```

### 2. SimpleAnimatedSplash
**Файл:** `lib/screens/splash/simple_animated_splash.dart`

**Особенности:**
- Простая анимация масштабирования и поворота
- Анимированный индикатор загрузки
- Минималистичный дизайн

### 3. LottieSplashScreen
**Файл:** `lib/screens/splash/lottie_splash_screen.dart`

**Особенности:**
- Поддержка Lottie анимаций
- Сложные анимированные фоны
- Волновые эффекты

## 🎯 Типы анимаций

### 1. FadeTransition
```dart
FadeTransition(
  opacity: _fadeAnimation,
  child: Widget(),
)
```

### 2. SlideTransition
```dart
SlideTransition(
  position: _slideAnimation,
  child: Widget(),
)
```

### 3. ScaleTransition
```dart
ScaleTransition(
  scale: _scaleAnimation,
  child: Widget(),
)
```

### 4. RotationTransition
```dart
RotationTransition(
  turns: _rotationAnimation,
  child: Widget(),
)
```

### 5. TweenAnimationBuilder
```dart
TweenAnimationBuilder<double>(
  duration: Duration(milliseconds: 500),
  tween: Tween(begin: 0.0, end: 1.0),
  builder: (context, value, child) {
    return Transform.scale(
      scale: value,
      child: Widget(),
    );
  },
)
```

## 🛠️ Создание собственных анимаций

### Шаг 1: Добавьте TickerProviderStateMixin
```dart
class MyWidget extends StatefulWidget with TickerProviderStateMixin {
  // ...
}
```

### Шаг 2: Создайте AnimationController
```dart
late AnimationController _controller;
late Animation<double> _animation;

@override
void initState() {
  super.initState();
  _controller = AnimationController(
    duration: Duration(milliseconds: 1000),
    vsync: this,
  );
  
  _animation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ));
}
```

### Шаг 3: Запустите анимацию
```dart
_controller.forward();
```

### Шаг 4: Используйте AnimatedBuilder
```dart
AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
    return Transform.scale(
      scale: _animation.value,
      child: Widget(),
    );
  },
)
```

### Шаг 5: Не забудьте dispose
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

## 🎨 Анимации в экранах

### 1. Экран профиля
- FadeTransition для появления элементов
- SlideTransition для движения карточек
- ScaleAnimation для кнопок

### 2. Экран специалиста
- Hero анимации для изображений
- Staggered анимации для списков
- TweenAnimationBuilder для интерактивных элементов

### 3. Экран чатов
- Анимации появления сообщений
- Анимации печати
- Плавные переходы между экранами

### 4. Экран заказов
- Анимации карточек заказов
- Анимации фильтров
- Анимации состояний загрузки

## 📱 Адаптивные анимации

### Учет размера экрана
```dart
final screenWidth = MediaQuery.of(context).size.width;
final animationDuration = screenWidth > 600 
    ? Duration(milliseconds: 800)
    : Duration(milliseconds: 600);
```

### Учет платформы
```dart
final isAndroid = Theme.of(context).platform == TargetPlatform.android;
final curve = isAndroid ? Curves.easeInOut : Curves.easeOutCubic;
```

## ⚡ Оптимизация производительности

### 1. Используйте const конструкторы
```dart
const SizedBox(height: 16), // ✅ Хорошо
SizedBox(height: 16),       // ❌ Плохо
```

### 2. Избегайте ненужных rebuilds
```dart
// Используйте AnimatedBuilder вместо setState
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Widget();
  },
)
```

### 3. Dispose контроллеры
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

## 🎭 Кастомные анимации

### 1. Создание кастомного painter
```dart
class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Ваша кастомная анимация
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### 2. Использование CustomPaint
```dart
CustomPaint(
  painter: MyCustomPainter(),
  size: Size.infinite,
)
```

## 🔧 Настройка анимаций

### Изменение длительности
```dart
AnimationController(
  duration: Duration(milliseconds: 1500), // Измените здесь
  vsync: this,
)
```

### Изменение кривой анимации
```dart
CurvedAnimation(
  parent: _controller,
  curve: Curves.elasticOut, // Измените здесь
)
```

### Доступные кривые
- `Curves.linear` - линейная
- `Curves.easeIn` - медленный старт
- `Curves.easeOut` - медленный конец
- `Curves.easeInOut` - медленный старт и конец
- `Curves.elasticOut` - упругая
- `Curves.bounceOut` - отскок

## 📚 Полезные ресурсы

1. [Flutter Animation Documentation](https://docs.flutter.dev/development/ui/animations)
2. [Material Design Motion](https://material.io/design/motion/)
3. [Lottie for Flutter](https://pub.dev/packages/lottie)

## 🎯 Лучшие практики

1. **Согласованность** - используйте одинаковые длительности и кривые
2. **Производительность** - избегайте сложных анимаций на слабых устройствах
3. **Доступность** - учитывайте настройки анимации пользователя
4. **Тестирование** - тестируйте анимации на разных устройствах
5. **Простота** - не перегружайте интерфейс анимациями

## 🚀 Примеры использования

### Анимация появления списка
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: ListTile(title: Text(items[index])),
          ),
        );
      },
    );
  },
)
```

### Анимация кнопки
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  transform: Matrix4.identity()..scale(isPressed ? 0.95 : 1.0),
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Нажми меня'),
  ),
)
```

---

**Создано для ODO.UZ** 🚀
*Версия: 1.0.0*
