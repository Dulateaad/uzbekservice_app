import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../models/firestore_models.dart';
import '../../services/firestore_service.dart';

final _monthStartProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final cityRatingsProvider = FutureProvider<List<CitySpecialistRating>>((ref) async {
  final monthStart = ref.watch(_monthStartProvider);
  return getCityRatingsByCategoryForMonth(monthStart);
});

class CityRatingsScreen extends ConsumerWidget {
  const CityRatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRatings = ref.watch(cityRatingsProvider);
    final monthStart = ref.watch(_monthStartProvider);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Рейтинг по городам'),
        centerTitle: true,
      ),
      body: Padding
        (
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(context, ref, monthStart),
            const SizedBox(height: AppConstants.spacingMD),
            Expanded(
              child: asyncRatings.when(
                data: (data) => _buildList(context, data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(
                  child: Text('Ошибка загрузки: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, WidgetRef ref, DateTime monthStart) {
    final months = <DateTime>[
      DateTime(monthStart.year, monthStart.month, 1),
      DateTime(monthStart.year, monthStart.month - 1, 1),
    ];

    String formatMonth(DateTime d) {
      const names = [
        'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
        'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
      ];
      return '${names[d.month - 1]} ${d.year}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Период',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        DropdownButton<DateTime>(
          value: monthStart,
          items: months.map((m) {
            return DropdownMenuItem(
              value: m,
              child: Text(formatMonth(m)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(_monthStartProvider.notifier).state = value;
            }
          },
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<CitySpecialistRating> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text('Нет данных за выбранный период'),
      );
    }

    // Группируем по городу и категории
    final Map<String, List<CitySpecialistRating>> byCity = {};
    for (final item in data) {
      final key = '${item.city}__${item.category}';
      byCity.putIfAbsent(key, () => []).add(item);
    }

    return ListView(
      children: byCity.entries.map((entry) {
        final parts = entry.key.split('__');
        final city = parts[0];
        final category = parts[1];
        final items = entry.value
          ..sort((a, b) => b.averageRating.compareTo(a.averageRating));

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          child: ExpansionTile(
            title: Text(
              '$city — $category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            children: [
              const Divider(height: 1),
              ...items.map((item) => ListTile(
                    title: Text(item.specialistName),
                    subtitle: Text('Заказов: ${item.totalOrders}, отзывов: ${item.totalReviews}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          item.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }
}
