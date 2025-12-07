import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../constants/app_constants.dart';
import '../../widgets/simple_google_maps_widget.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  double _currentLat = 41.2995; // Ташкент
  double _currentLng = 69.2401;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    try {
      // Получаем текущее местоположение (только для веб)
      // Для Android используем значения по умолчанию (Ташкент)
      if (kIsWeb) {
        // На веб-платформе можно использовать геолокацию браузера
        // Но для Android сборки этот код не выполняется
        print('📍 Используем местоположение по умолчанию для Android');
      }
      
    } catch (e) {
      print('❌ Ошибка инициализации карты: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Заголовок
              const Text(
                'Карты',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Найдите специалистов рядом с вами',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Google Maps
              Expanded(
                child: _isLoading
                    ? Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 20),
                              const Text(
                                'Загрузка карты...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : kIsWeb
                        ? SimpleGoogleMapsWidget(
                            lat: _currentLat,
                            lng: _currentLng,
                            zoom: 15,
                            height: double.infinity,
                          )
                        : Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_rounded,
                                    size: 80,
                                    color: AppConstants.primaryColor.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Карта',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Google Maps доступна только в веб-версии',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
              
              const SizedBox(height: 100), // Отступ для навигации
            ],
          ),
        ),
      ),
    );
  }
}