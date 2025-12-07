import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uni_links/uni_links.dart'; // Удален устаревший пакет
import '../services/oneid_service.dart';
import '../config/oneid_config.dart';

/// Провайдер для обработки OneID deep links
/// Временно отключен из-за удаления uni_links
/// TODO: Использовать app_links или другой пакет для deep links
final oneIdDeepLinkProvider = StreamProvider<String?>((ref) {
  // return linkStream; // Временно отключено
  return Stream<String?>.value(null);
});

/// Провайдер для OneID сервиса
final oneIdServiceProvider = Provider<OneIdService>((ref) {
  return OneIdService();
});

/// Провайдер для обработки OneID авторизации
final oneIdAuthResultProvider = StateProvider<OneIdAuthResult?>((ref) {
  return null;
});

/// Провайдер для состояния загрузки OneID
final oneIdLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

/// Инициализация deep link слушателя
class OneIdDeepLinkListener {
  final WidgetRef ref;
  StreamSubscription? _linkSubscription;

  OneIdDeepLinkListener(this.ref);

  void init() {
    // TODO: Реализовать с использованием app_links или другого пакета
    // Временно отключено из-за удаления uni_links
    // Обработка начального deep link (если приложение открылось по ссылке)
    // _handleInitialLink();

    // Подписка на последующие deep links
    // _linkSubscription = linkStream.listen((String? link) {
    //   if (link != null) {
    //     _handleDeepLink(link);
    //   }
    // }, onError: (err) {
    //   print('❌ Ошибка deep link: $err');
    // });
  }

  Future<void> _handleInitialLink() async {
    // TODO: Реализовать с использованием app_links или другого пакета
    // Временно отключено из-за удаления uni_links
    // try {
    //   final initialLink = await getInitialLink();
    //   if (initialLink != null) {
    //     _handleDeepLink(initialLink);
    //   }
    // } catch (e) {
    //   print('❌ Ошибка получения начального deep link: $e');
    // }
  }

  void _handleDeepLink(String link) async {
    print('📥 Получен deep link: $link');

    // Проверяем, что это OneID callback
    if (!OneIdConfig.isOneIdCallback(link)) {
      print('⚠️ Deep link не является OneID callback');
      return;
    }

    ref.read(oneIdLoadingProvider.notifier).state = true;

    try {
      final oneIdService = ref.read(oneIdServiceProvider);
      final result = await oneIdService.handleCallback(link);

      ref.read(oneIdAuthResultProvider.notifier).state = result;
    } catch (e) {
      print('❌ Ошибка обработки OneID callback: $e');
      ref.read(oneIdAuthResultProvider.notifier).state = OneIdAuthResult.failure(
        'Ошибка обработки ответа: $e',
      );
    } finally {
      ref.read(oneIdLoadingProvider.notifier).state = false;
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}

