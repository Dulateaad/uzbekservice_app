import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../widgets/island_navigation.dart';
import '../home/beautiful_home_screen.dart';
import '../home/client_home_screen.dart';
import '../home/new_client_home_screen.dart';
import '../home/specialist_home_screen.dart';
import '../profile/profile_screen.dart';
import '../maps/maps_screen.dart';
import '../orders/orders_screen.dart';
import '../../providers/firestore_auth_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firestoreAuthProvider);
    final user = authState.user;

    // Определяем экраны в зависимости от роли пользователя
    List<Widget> screens;
    List<NavigationItem> navigationItems;
    
    if (user?.userType == 'specialist') {
      screens = [
        const SpecialistHomeScreen(),
        const ProfileScreen(),
        const MapsScreen(),
        const OrdersScreen(),
      ];
      navigationItems = [
        const NavigationItem(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Панель',
        ),
        const NavigationItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Профиль',
        ),
        const NavigationItem(
          icon: Icons.map_outlined,
          selectedIcon: Icons.map,
          label: 'Карты',
        ),
        const NavigationItem(
          icon: Icons.work_outline,
          selectedIcon: Icons.work,
          label: 'Заказы',
        ),
      ];
    } else {
      screens = [
        const NewClientHomeScreen(),
        const ProfileScreen(),
        const MapsScreen(),
        const OrdersScreen(),
      ];
      navigationItems = [
        const NavigationItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Главная',
        ),
        const NavigationItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Профиль',
        ),
        const NavigationItem(
          icon: Icons.map_outlined,
          selectedIcon: Icons.map,
          label: 'Карты',
        ),
        const NavigationItem(
          icon: Icons.shopping_bag_outlined,
          selectedIcon: Icons.shopping_bag,
          label: 'Заказы',
        ),
      ];
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          screens[_currentIndex],
          IslandNavigation(
            currentIndex: _currentIndex,
            items: navigationItems,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
