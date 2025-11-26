import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_router.dart';
import 'config/supabase_config.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // В тестовом режиме (debug) держим экран включенным
  if (kDebugMode) {
    await WakelockPlus.enable();
    print('🔋 Режим тестирования: экран будет оставаться включенным');
  }
  
  runApp(
    const ProviderScope(
      child: UzbekistanServiceApp(),
    ),
  );
}

class UzbekistanServiceApp extends ConsumerWidget {
  const UzbekistanServiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ODO.UZ',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme,
      
      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'), // Russian
        Locale('uz', 'UZ'), // Uzbek
        Locale('en', 'US'), // English
      ],
      locale: const Locale('ru', 'RU'),
      
      // Routing
      routerConfig: AppRouter.router,
    );
  }
}
