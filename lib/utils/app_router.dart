import 'package:flutter/material.dart';
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
          final phoneNumber = state.extra as String?;
          return SmsVerificationScreen(phoneNumber: phoneNumber ?? '');
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
          GoRoute(
            path: 'specialist/:specialistId',
            builder: (context, state) {
              final specialistId = state.pathParameters['specialistId']!;
              return SpecialistDetailScreen(specialistId: specialistId);
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
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Страница не найдена',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Путь: ${state.uri.path}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
}
