# ODO.UZ Design System Implementation

## Обзор

Приложение ODO.UZ теперь использует современную дизайн-систему, основанную на принципах Material 3 и лучших практиках UX/UI дизайна.

## Цветовая палитра

### Основные цвета
- **Primary (Sky Blue)**: `#0EA5E9` - основной цвет бренда
- **Primary Light**: `#38BDF8` - светлый оттенок
- **Primary Dark**: `#0284C7` - темный оттенок
- **Primary Contrast**: `#FFFFFF` - контрастный цвет

### Вторичные цвета
- **Secondary (Lime Green)**: `#84CC16` - акцентный цвет
- **Secondary Light**: `#A3E635` - светлый оттенок
- **Secondary Dark**: `#65A30D` - темный оттенок
- **Secondary Contrast**: `#FFFFFF` - контрастный цвет

### Нейтральные цвета
- **Background**: `#F9FAFB` - фон приложения
- **Surface**: `#FFFFFF` - фон карточек и элементов
- **Border**: `#E5E7EB` - границы элементов
- **Divider**: `#D1D5DB` - разделители

### Семантические цвета
- **Success**: `#10B981` - успех
- **Warning**: `#F59E0B` - предупреждение
- **Error**: `#EF4444` - ошибка
- **Info**: `#3B82F6` - информация

### Цвета категорий
- **Barber**: `#8B5CF6` (фиолетовый)
- **Nanny**: `#EC4899` (розовый)
- **Handyman**: `#F97316` (оранжевый)
- **Construction**: `#14B8A6` (бирюзовый)
- **Medical**: `#EF4444` (красный)
- **Other**: `#6B7280` (серый)

## Типографика

### Шрифты
- **Primary**: `SF Pro Display, -apple-system, Roboto, sans-serif`
- **Secondary**: `SF Pro Text, -apple-system, Roboto, sans-serif`

### Размеры шрифтов
- **H1**: 28px, weight 700, letter-spacing -0.5
- **H2**: 24px, weight 700, letter-spacing -0.3
- **H3**: 20px, weight 600, letter-spacing -0.2
- **Subtitle1**: 18px, weight 600
- **Subtitle2**: 16px, weight 600
- **Body1**: 16px, weight 400
- **Body2**: 14px, weight 400
- **Caption**: 12px, weight 400
- **Button**: 16px, weight 600

## Отступы и размеры

### Spacing
- **XS**: 4px
- **SM**: 8px
- **MD**: 16px
- **LG**: 24px
- **XL**: 32px
- **XXL**: 48px

### Border Radius
- **XS**: 4px
- **SM**: 8px
- **MD**: 12px
- **LG**: 16px
- **XL**: 20px
- **XXL**: 24px
- **Round**: 999px

## Компоненты

### Кнопки

#### Primary Button
- Фон: Primary Color
- Текст: Primary Contrast
- Высота: 56px
- Border Radius: 16px
- Elevation: 4px

#### Secondary Button
- Фон: Surface Color
- Текст: Primary Color
- Граница: Primary Color (2px)
- Высота: 56px
- Border Radius: 16px

#### Accent Button
- Фон: Secondary Color
- Текст: Secondary Contrast
- Высота: 56px
- Border Radius: 16px
- Elevation: 4px

#### Ghost Button
- Фон: Transparent
- Текст: Text Secondary
- Высота: 48px
- Border Radius: 12px

#### Icon Button
- Размер: 48x48px
- Фон: Background Color
- Border Radius: 24px (round)

### Карточки

#### Category Card
- Фон: Surface Color
- Border Radius: 20px
- Граница: Border Color (1px)
- Padding: 20px
- Elevation: 4px
- Иконка: 56x56px в контейнере с цветом категории

#### Specialist Card
- Фон: Surface Color
- Border Radius: 20px
- Граница: Border Color (1px) или Secondary Color для featured
- Padding: 16px
- Elevation: 4px или 12px для featured
- Аватар: 72x72px с Border Radius 16px

### Навигация

#### Island Navigation
- Позиция: Fixed bottom
- Отступы: 24px от краев
- Фон: Surface Color
- Border Radius: 24px
- Граница: Primary Color с прозрачностью 0.1
- Elevation: 8px
- Анимация: 200ms ease-out

### Поисковая строка

#### Search Bar
- Фон: Background Color (обычное состояние) / Surface Color (фокус)
- Border Radius: 16px
- Граница: Primary Color (2px) при фокусе
- Padding: 16px
- Минимальная высота: 48px
- Elevation: 2px при фокусе

## Анимации

### Длительность
- **Button**: 200ms
- **Modal**: 300ms
- **Transition**: 250ms

### Easing
- **Button**: ease-out
- **Modal**: cubic-bezier(0.4, 0, 0.2, 1)
- **Transition**: ease-in-out

## Использование

### Импорт компонентов
```dart
import '../widgets/design_system_button.dart';
import '../widgets/category_card.dart';
import '../widgets/specialist_card.dart';
import '../widgets/island_navigation.dart';
import '../widgets/search_bar.dart';
```

### Пример использования кнопки
```dart
DesignSystemButton(
  text: 'Заказать',
  icon: Icons.shopping_bag,
  type: ButtonType.primary,
  onPressed: () {
    // Действие
  },
)
```

### Пример использования карточки категории
```dart
CategoryCard(
  id: 'barber',
  name: 'Барберы',
  icon: Icons.content_cut,
  color: AppConstants.categoryBarberColor,
  emoji: '✂️',
  onTap: () {
    // Навигация
  },
)
```

### Пример использования карточки специалиста
```dart
SpecialistCard(
  name: 'Алишер Усманов',
  category: 'Барбер',
  location: 'Ташкент, Чилонзар',
  rating: 4.8,
  reviewCount: 127,
  isFeatured: true,
  onTap: () {
    // Открыть профиль
  },
  onBook: () {
    // Заказать услугу
  },
)
```

## Преимущества новой дизайн-системы

1. **Консистентность**: Единообразный дизайн во всем приложении
2. **Доступность**: Соответствие стандартам доступности
3. **Производительность**: Оптимизированные компоненты
4. **Масштабируемость**: Легко добавлять новые компоненты
5. **Современность**: Использование последних трендов в дизайне
6. **Брендинг**: Укрепление визуальной идентичности ODO.UZ

## Следующие шаги

1. Обновить остальные экраны приложения
2. Добавить темную тему
3. Создать дополнительные компоненты (модальные окна, уведомления)
4. Оптимизировать для различных размеров экранов
5. Добавить анимации и микроинтеракции
