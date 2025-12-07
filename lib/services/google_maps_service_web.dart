import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

class GoogleMapsService {
  static bool _isInitialized = false;
  static bool _isMapReady = false;
  
  // Callback для уведомления о готовности карт
  static Function? _onMapsReady;
  
  /// Инициализация Google Maps
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🗺️ Инициализация Google Maps...');
    
    // Проверяем, загружен ли Google Maps API
    if (js.context['google'] != null) {
      _isInitialized = true;
      _isMapReady = true;
      print('✅ Google Maps API уже загружен');
      return;
    }
    
    // Динамически загружаем Google Maps API
    try {
      await _loadGoogleMapsAPI();
      _isInitialized = true;
      _isMapReady = true;
      print('✅ Google Maps API загружен динамически');
    } catch (e) {
      print('❌ Ошибка загрузки Google Maps API: $e');
      // Fallback к ожиданию
      _waitForGoogleMaps();
    }
  }
  
  /// Динамическая загрузка Google Maps API
  static Future<void> _loadGoogleMapsAPI() async {
    final completer = Completer<void>();
    
    // Вызываем JavaScript функцию для загрузки API
    // Используем прямые функции без allowInterop (не требуется в новых версиях Dart)
    final successCallback = () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    };
    final errorCallback = (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    };
    js.context.callMethod('loadGoogleMapsAPI', [successCallback, errorCallback]);
    
    return completer.future;
  }
  
  /// Ожидание загрузки Google Maps API
  static void _waitForGoogleMaps() {
    const maxAttempts = 50; // 5 секунд максимум
    int attempts = 0;
    
    void checkGoogleMaps() {
      attempts++;
      
      if (js.context['google'] != null) {
        _isInitialized = true;
        _isMapReady = true;
        print('✅ Google Maps API загружен успешно');
        
        // Вызываем callback если есть
        if (_onMapsReady != null) {
          _onMapsReady!();
        }
        return;
      }
      
      if (attempts < maxAttempts) {
        Future.delayed(const Duration(milliseconds: 100), checkGoogleMaps);
      } else {
        print('❌ Google Maps API не загрузился за отведенное время');
      }
    }
    
    checkGoogleMaps();
  }
  
  /// Установка callback для готовности карт
  static void setOnMapsReady(Function callback) {
    _onMapsReady = callback;
    
    // Если карты уже готовы, вызываем callback сразу
    if (_isMapReady) {
      callback();
    }
  }
  
  /// Проверка готовности Google Maps
  static bool get isReady => _isMapReady;
  
  /// Создание карты
  static Future<dynamic> createMap({
    required String containerId,
    required double lat,
    required double lng,
    required int zoom,
    List<String>? markers,
  }) async {
    if (!_isMapReady) {
      throw Exception('Google Maps не готов');
    }
    
    try {
      // Получаем контейнер для карты
      final container = html.document.getElementById(containerId);
      if (container == null) {
        throw Exception('Контейнер с id $containerId не найден');
      }

      final google = js.context['google'];
      if (google == null) {
        throw Exception('Google namespace не найден');
      }

      final maps = google['maps'];
      if (maps == null) {
        throw Exception('Google Maps API недоступен');
      }

      final mapConstructor = maps['Map'];
      if (mapConstructor == null) {
        throw Exception('Map constructor отсутствует');
      }

      // Создаем опции карты
      final mapOptions = js.JsObject.jsify({
        'center': {'lat': lat, 'lng': lng},
        'zoom': zoom,
        'mapTypeId': 'roadmap',
        'styles': _getMapStyles(),
      });

      final map = js.JsObject(mapConstructor, [container, mapOptions]);

      print('✅ Google Maps создана успешно');
      return map;
    } catch (e) {
      print('❌ Ошибка создания Google Maps: $e');
      rethrow;
    }
  }
  
  /// Добавление маркера на карту
  static dynamic addMarker({
    required dynamic map,
    required double lat,
    required double lng,
    String? title,
    String? icon,
  }) {
    if (!_isMapReady) {
      throw Exception('Google Maps не готов');
    }
    
    try {
      final google = js.context['google'];
      if (google == null) {
        throw Exception('Google namespace не найден');
      }

      final maps = google['maps'];
      if (maps == null) {
        throw Exception('Google Maps API недоступен');
      }

      final markerConstructor = maps['Marker'];
      if (markerConstructor == null) {
        throw Exception('Marker constructor отсутствует');
      }

      final markerOptions = js.JsObject.jsify({
        'position': {'lat': lat, 'lng': lng},
        'map': map,
        'title': title ?? '',
        'icon': icon,
      });

      final marker = js.JsObject(markerConstructor, [markerOptions]);

      print('✅ Маркер добавлен: $lat, $lng');
      return marker;
    } catch (e) {
      print('❌ Ошибка добавления маркера: $e');
      rethrow;
    }
  }
  
  /// Получение стилей карты
  static List<dynamic> _getMapStyles() {
    return [
      {
        "featureType": "all",
        "elementType": "geometry.fill",
        "stylers": [
          {"weight": "2.00"}
        ]
      },
      {
        "featureType": "all",
        "elementType": "geometry.stroke",
        "stylers": [
          {"color": "#9c9c9c"}
        ]
      },
      {
        "featureType": "all",
        "elementType": "labels.text",
        "stylers": [
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "landscape",
        "elementType": "all",
        "stylers": [
          {"color": "#f2f2f2"}
        ]
      },
      {
        "featureType": "landscape",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#ffffff"}
        ]
      },
      {
        "featureType": "landscape.man_made",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#ffffff"}
        ]
      },
      {
        "featureType": "poi",
        "elementType": "all",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "all",
        "stylers": [
          {"saturation": -100},
          {"lightness": 45}
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#eeeeee"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#7b7b7b"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#ffffff"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "all",
        "stylers": [
          {"visibility": "simplified"}
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.icon",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "transit",
        "elementType": "all",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "all",
        "stylers": [
          {"color": "#46bcec"},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#c8d7d4"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#070707"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#ffffff"}
        ]
      }
    ];
  }
  
  /// Поиск мест
  static Future<List<Map<String, dynamic>>> searchPlaces({
    required String query,
    required double lat,
    required double lng,
    int radius = 5000,
  }) async {
    if (!_isMapReady) {
      throw Exception('Google Maps не готов');
    }
    
    try {
      // Создаем сервис Places
      final placesService = js.context['google']['maps']['places']['PlacesService'];
      final map = await createMap(
        containerId: 'temp-map',
        lat: lat,
        lng: lng,
        zoom: 15,
      );
      
      final service = placesService.callAsConstructor(map);
      
      // Создаем запрос
      final request = js.JsObject.jsify({
        'query': query,
        'location': {'lat': lat, 'lng': lng},
        'radius': radius,
      });
      
      // Выполняем поиск
      final results = <Map<String, dynamic>>[];
      
      service.textSearch(request, (places, status) {
        if (status == 'OK') {
          for (int i = 0; i < places.length; i++) {
            final place = places[i];
            results.add({
              'name': place['name'],
              'formatted_address': place['formatted_address'],
              'geometry': {
                'location': {
                  'lat': place['geometry']['location']['lat'](),
                  'lng': place['geometry']['location']['lng'](),
                }
              },
              'rating': place['rating'],
              'place_id': place['place_id'],
            });
          }
        }
      });
      
      return results;
    } catch (e) {
      print('❌ Ошибка поиска мест: $e');
      return [];
    }
  }
  
  /// Получение текущего местоположения
  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      final position = await html.window.navigator.geolocation.getCurrentPosition();
      if (position.coords != null) {
        return {
          'lat': position.coords!.latitude?.toDouble() ?? 41.2995,
          'lng': position.coords!.longitude?.toDouble() ?? 69.2401,
        };
      }
      return null;
    } catch (e) {
      print('❌ Ошибка получения местоположения: $e');
      // Возвращаем координаты Ташкента по умолчанию
      return {
        'lat': 41.2995,
        'lng': 69.2401,
      };
    }
  }
  
  /// Функция для получения API ключа
  static String getGoogleMapsApiKey() {
    return 'AIzaSyAomtM5KaHgrG95yTVN5Wirn46Qgq--yKY';
  }
}
