import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/firestore_models.dart';
import '../providers/firestore_auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/splash_screen.dart' as onboarding;
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/phone_auth_screen.dart';
import '../screens/auth/beautiful_login_screen.dart';
import '../screens/auth/sms_verification_screen.dart';
import '../screens/auth/create_profile_screen.dart';
import '../screens/auth/oneid_auth_screen.dart';
import '../screens/auth/specialist_registration_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/new_client_home_screen.dart';
import '../screens/home/categories_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/specialist/specialist_detail_screen.dart';
import '../screens/specialist/enhanced_specialist_detail_screen.dart';
import '../screens/booking/service_selection_screen.dart';
import '../screens/booking/date_time_screen.dart';
import '../screens/booking/address_screen.dart';
import '../screens/booking/confirmation_screen.dart';
import '../screens/booking/success_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/maps/maps_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/specialist/specialist_list_screen.dart';
import '../screens/specialist/specialist_detail_screen.dart';
import '../screens/order/order_creation_screen.dart';
import '../screens/order/order_detail_screen.dart';
import '../screens/order/order_history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/specialist_profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/fixed_edit_profile_screen.dart';
import '../screens/profile/favorites_screen.dart';
import '../screens/profile/payment_methods_screen.dart';
import '../screens/analytics/city_ratings_screen.dart';
import '../screens/payment/payment_selection_screen.dart';
import '../screens/payment/click_payment_screen.dart';
import '../screens/payment/payment_success_screen.dart';
import '../screens/legal/privacy_policy_screen.dart';
import '../screens/legal/terms_of_service_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final authState = container.read(firestoreAuthProvider);
      
      print('Redirect check: path=${state.uri.path}, authenticated=${authState.isAuthenticated}');
      
      // Если пользователь не аутентифицирован и не на экранах аутентификации или онбординга
      if (!authState.isAuthenticated && 
          !state.uri.path.startsWith('/auth') && 
          state.uri.path != '/splash' &&
          state.uri.path != '/onboarding') {
        print('Redirecting to /auth/phone - user not authenticated');
        return '/auth/phone';
      }
      
      // Если пользователь аутентифицирован, но на экране создания профиля - разрешаем
      if (authState.isAuthenticated && state.uri.path == '/auth/create-profile') {
        return null;
      }
      
      // Если пользователь аутентифицирован и на экране аутентификации
      if (authState.isAuthenticated && state.uri.path.startsWith('/auth')) {
        print('Redirecting to /home - user authenticated but on auth screen');
        return '/home';
      }
      
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const onboarding.SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const BeautifulLoginScreen(),
      ),
      GoRoute(
        path: '/auth/sms',
        builder: (context, state) {
          // Поддерживаем как старый формат (String), так и новый (Map)
          String phoneNumber = '';
          String? verificationId;
          
          if (state.extra is Map) {
            final extra = state.extra as Map<String, dynamic>;
            phoneNumber = extra['phoneNumber'] as String? ?? '';
            verificationId = extra['verificationId'] as String?;
          } else if (state.extra is String) {
            phoneNumber = state.extra as String;
          }
          
          return SmsVerificationScreen(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
          );
        },
      ),
      GoRoute(
        path: '/auth/oneid',
        builder: (context, state) {
          final phoneNumber = state.extra as String?;
          return OneIdAuthScreen(phoneNumber: phoneNumber ?? '');
        },
      ),
      GoRoute(
        path: '/auth/oneid/callback',
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          final stateParam = state.uri.queryParameters['state'];
          final phoneNumber = state.extra as String?;
          return OneIdAuthScreen(
            phoneNumber: phoneNumber ?? '',
            code: code,
            state: stateParam,
          );
        },
      ),
      GoRoute(
        path: '/auth/create-profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: '/auth/specialist-registration',
        builder: (context, state) => const SpecialistRegistrationScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
        routes: [
          // Categories
          GoRoute(
            path: 'categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          
          // Search
          GoRoute(
            path: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          
            // Specialists
            GoRoute(
              path: 'specialists/:categoryId',
              builder: (context, state) {
                final categoryId = state.pathParameters['categoryId']!;
                return SpecialistListScreen(categoryId: categoryId);
              },
            ),

            // Specialist Detail
            GoRoute(
              path: 'specialist/:specialistId',
              builder: (context, state) {
                final specialistId = state.pathParameters['specialistId']!;
                // Используем улучшенный экран с табами
                return EnhancedSpecialistDetailScreen(specialistId: specialistId);
              },
            ),

            // Booking Flow
            GoRoute(
              path: 'booking/service-selection/:specialistId',
              builder: (context, state) {
                final specialistId = state.pathParameters['specialistId']!;
                return ServiceSelectionScreen(specialistId: specialistId);
              },
            ),
            GoRoute(
              path: 'booking/date-time/:specialistId',
              builder: (context, state) {
                final specialistId = state.pathParameters['specialistId']!;
                return DateTimeScreen(specialistId: specialistId);
              },
            ),
            GoRoute(
              path: 'booking/address/:specialistId',
              builder: (context, state) {
                final specialistId = state.pathParameters['specialistId']!;
                return AddressScreen(specialistId: specialistId);
              },
            ),
            GoRoute(
              path: 'booking/confirmation/:specialistId',
              builder: (context, state) {
                final specialistId = state.pathParameters['specialistId']!;
                return ConfirmationScreen(specialistId: specialistId);
              },
            ),
            GoRoute(
              path: 'booking/success/:specialistId',
              builder: (context, state) {
                final specialistId = state.pathParameters['specialistId']!;
                final order = state.extra as FirestoreOrder?;
                if (order == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Заказ не найден'),
                    ),
                  );
                }
                return BookingSuccessScreen(
                  specialistId: specialistId,
                  order: order,
                );
              },
            ),
          
          // Orders
          GoRoute(
            path: 'order/create/:specialistId',
            builder: (context, state) {
              final specialistId = state.pathParameters['specialistId']!;
              return OrderCreationScreen(specialistId: specialistId);
            },
          ),
          GoRoute(
            path: 'order/:orderId',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return OrderDetailScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) => const OrdersScreen(),
          ),

          // Chats
          GoRoute(
            path: 'chats',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: 'chat/:chatId',
            builder: (context, state) {
              final chatId = state.pathParameters['chatId']!;
              return ChatScreen(chatId: chatId);
            },
          ),
          
          // Profile
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
          GoRoute(
            path: 'edit-with-photo',
            builder: (context, state) => const FixedEditProfileScreen(),
          ),
              GoRoute(
                path: 'specialist',
                builder: (context, state) => const SpecialistProfileScreen(),
              ),
              GoRoute(
                path: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
              GoRoute(
                path: 'payment-methods',
                builder: (context, state) => const PaymentMethodsScreen(),
              ),
              GoRoute(
                path: 'analytics-city-ratings',
                builder: (context, state) => const CityRatingsScreen(),
              ),
            ],
          ),
          
          // Legal
          GoRoute(
            path: 'privacy-policy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: 'terms-of-service',
            builder: (context, state) => const TermsOfServiceScreen(),
          ),
        ],
      ),
      
      // Payment Routes
      GoRoute(
        path: '/payment/select',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentSelectionScreen(
            orderId: extra?['orderId'] ?? '',
            amount: (extra?['amount'] ?? 0).toDouble(),
            specialistName: extra?['specialistName'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/payment/click',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ClickPaymentScreen(
            orderId: extra?['orderId'] ?? '',
            amount: (extra?['amount'] ?? 0).toDouble(),
            specialistName: extra?['specialistName'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/payment/success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentSuccessScreen(
            orderId: extra?['orderId'] ?? '',
            paymentMethod: extra?['paymentMethod'] ?? 'click',
            amount: extra?['amount']?.toDouble(),
          );
        },
      ),
      
      // Orders direct route
      GoRoute(
        path: '/orders/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      
      // Specialist direct route (для совместимости)
      GoRoute(
        path: '/specialist/:specialistId',
        builder: (context, state) {
          final specialistId = state.pathParameters['specialistId']!;
          return EnhancedSpecialistDetailScreen(specialistId: specialistId);
        },
      ),
      
      // Chat direct route
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatScreen(chatId: chatId);
        },
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(state: state),
  );
}

/// Экран ошибки с возможностью копирования
class _ErrorScreen extends StatelessWidget {
  final GoRouterState state;

  const _ErrorScreen({required this.state});

  @override
  Widget build(BuildContext context) {
    final errorInfo = '''
🚨 ОШИБКА НАВИГАЦИИ

📍 Путь: ${state.uri.path}
🔗 Полный URL: ${state.uri}
📦 Query параметры: ${state.uri.queryParameters}
🏷️ Path параметры: ${state.pathParameters}
📝 Extra данные: ${state.extra}
⚠️ Ошибка: ${state.error}

📱 Время: ${DateTime.now()}
''';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.red.shade600,
        title: const Text(
          'Ошибка',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () => _copyError(context, errorInfo),
            tooltip: 'Копировать ошибку',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Иконка ошибки
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            
            // Заголовок
            Text(
              'Страница не найдена',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            Text(
              'Запрошенный путь не существует',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Детали ошибки
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, 
                        size: 20, 
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Детали ошибки',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Путь', state.uri.path),
                  _buildInfoRow('Полный URL', state.uri.toString()),
                  if (state.uri.queryParameters.isNotEmpty)
                    _buildInfoRow('Query', state.uri.queryParameters.toString()),
                  if (state.pathParameters.isNotEmpty)
                    _buildInfoRow('Path параметры', state.pathParameters.toString()),
                  if (state.extra != null)
                    _buildInfoRow('Extra', state.extra.toString()),
                  if (state.error != null)
                    _buildInfoRow('Ошибка', state.error.toString()),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Кнопка копирования
            ElevatedButton.icon(
              onPressed: () => _copyError(context, errorInfo),
              icon: const Icon(Icons.copy),
              label: const Text('Скопировать ошибку'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Кнопка на главную
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home),
              label: const Text('На главную'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Кнопка назад
            OutlinedButton.icon(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go('/home');
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Назад'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _copyError(BuildContext context, String errorInfo) {
    Clipboard.setData(ClipboardData(text: errorInfo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Ошибка скопирована в буфер обмена'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
