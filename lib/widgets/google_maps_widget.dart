import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/google_maps_service.dart';

class GoogleMapsWidget extends StatefulWidget {
  final double lat;
  final double lng;
  final int zoom;
  final List<MapMarker>? markers;
  final bool showCurrentLocation;
  final Function(double lat, double lng)? onLocationChanged;
  final double height;
  final double width;

  const GoogleMapsWidget({
    super.key,
    required this.lat,
    required this.lng,
    this.zoom = 15,
    this.markers,
    this.showCurrentLocation = false,
    this.onLocationChanged,
    this.height = 300,
    this.width = double.infinity,
  });

  @override
  State<GoogleMapsWidget> createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  String? _mapId;
  bool _isMapReady = false;
  dynamic _mapInstance;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    try {
      // Генерируем уникальный ID для карты
      _mapId = 'google-map-${DateTime.now().millisecondsSinceEpoch}';
      
      // Регистрируем HTML виджет только для веб
      if (kIsWeb) {
        ui_web.platformViewRegistry.registerViewFactory(
          _mapId!,
          (int viewId) {
            final div = html.DivElement()
              ..id = _mapId!
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.border = 'none';
            
            return div;
          },
        );
      }

      // Инициализируем Google Maps
      await GoogleMapsService.initialize();
      
      // Ждем готовности карт
      GoogleMapsService.setOnMapsReady(() {
        _createMap();
      });
      
      setState(() {});
    } catch (e) {
      print('❌ Ошибка инициализации карты: $e');
    }
  }

  void _createMap() async {
    try {
      if (_mapId == null) return;
      
      // Создаем карту
      _mapInstance = await GoogleMapsService.createMap(
        containerId: _mapId!,
        lat: widget.lat,
        lng: widget.lng,
        zoom: widget.zoom,
      );
      
      // Добавляем маркеры
      if (widget.markers != null) {
        for (final marker in widget.markers!) {
          GoogleMapsService.addMarker(
            map: _mapInstance,
            lat: marker.lat,
            lng: marker.lng,
            title: marker.title,
            icon: marker.icon,
          );
        }
      }
      
      // Показываем текущее местоположение
      if (widget.showCurrentLocation) {
        final location = await GoogleMapsService.getCurrentLocation();
        if (location != null) {
          GoogleMapsService.addMarker(
            map: _mapInstance,
            lat: location['lat']!,
            lng: location['lng']!,
            title: 'Мое местоположение',
            icon: 'data:image/svg+xml;charset=UTF-8,<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="%2300E676"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>',
          );
        }
      }
      
      // Добавляем обработчик клика на карту
      if (widget.onLocationChanged != null) {
        _addMapClickListener();
      }
      
      setState(() {
        _isMapReady = true;
      });
      
      print('✅ Google Maps виджет создан успешно');
    } catch (e) {
      print('❌ Ошибка создания карты: $e');
    }
  }

  void _addMapClickListener() {
    // Добавляем обработчик клика на карту
    // Это требует дополнительной настройки в JavaScript
  }

  @override
  Widget build(BuildContext context) {
    if (_mapId == null || !kIsWeb) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: HtmlElementView(
          viewType: _mapId!,
        ),
      ),
    );
  }
}

/// Класс для маркеров на карте
class MapMarker {
  final double lat;
  final double lng;
  final String? title;
  final String? icon;

  const MapMarker({
    required this.lat,
    required this.lng,
    this.title,
    this.icon,
  });
}

/// Виджет для выбора местоположения
class LocationPickerWidget extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final Function(double lat, double lng) onLocationSelected;
  final String? hint;

  const LocationPickerWidget({
    super.key,
    this.initialLat,
    this.initialLng,
    required this.onLocationSelected,
    this.hint,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  double _selectedLat = 41.2995; // Ташкент по умолчанию
  double _selectedLng = 69.2401;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedLat = widget.initialLat!;
      _selectedLng = widget.initialLng!;
    }
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      final location = await GoogleMapsService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _selectedLat = location['lat']!;
          _selectedLng = location['lng']!;
        });
      }
    } catch (e) {
      print('❌ Ошибка получения местоположения: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.hint != null) ...[
          Text(
            widget.hint!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMapsWidget(
                  lat: _selectedLat,
                  lng: _selectedLng,
                  zoom: 15,
                  showCurrentLocation: true,
                  onLocationChanged: (lat, lng) {
                    setState(() {
                      _selectedLat = lat;
                      _selectedLng = lng;
                    });
                    widget.onLocationSelected(lat, lng);
                  },
                ),
        ),
        
        const SizedBox(height: 16),
        
        // Кнопка подтверждения
        ElevatedButton(
          onPressed: () {
            widget.onLocationSelected(_selectedLat, _selectedLng);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E676),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Выбрать это местоположение',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
