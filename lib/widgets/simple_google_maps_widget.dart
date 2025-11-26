import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/google_maps_service.dart';

class SimpleGoogleMapsWidget extends StatefulWidget {
  final double lat;
  final double lng;
  final int zoom;
  final double height;
  final double width;

  const SimpleGoogleMapsWidget({
    super.key,
    required this.lat,
    required this.lng,
    this.zoom = 15,
    this.height = 300,
    this.width = double.infinity,
  });

  @override
  State<SimpleGoogleMapsWidget> createState() => _SimpleGoogleMapsWidgetState();
}

class _SimpleGoogleMapsWidgetState extends State<SimpleGoogleMapsWidget> {
  static const String _viewType = 'simple-google-map-view';
  static bool _isViewFactoryRegistered = false;

  bool _isMapReady = false;
  bool _initializationError = false;
  late final Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initialize();
  }

  Future<void> _initialize() async {
    if (!kIsWeb) return;

    try {
      if (!_isViewFactoryRegistered) {
        ui_web.platformViewRegistry.registerViewFactory(
          _viewType,
          (int viewId) {
            final div = html.DivElement()
              ..id = _containerIdForView(viewId)
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.border = 'none';
            return div;
          },
        );
        _isViewFactoryRegistered = true;
      }

      await GoogleMapsService.initialize();
    } catch (e) {
      _initializationError = true;
      print('❌ Ошибка инициализации Google Maps: $e');
    }
    if (mounted) {
      setState(() {});
    }
  }

  String _containerIdForView(int viewId) => '$_viewType-$viewId';

  Future<void> _onPlatformViewCreated(int viewId) async {
    if (!kIsWeb || _initializationError) return;
    try {
      await _initializeFuture;
      final map = await GoogleMapsService.createMap(
        containerId: _containerIdForView(viewId),
        lat: widget.lat,
        lng: widget.lng,
        zoom: widget.zoom,
      );
      GoogleMapsService.addMarker(
        map: map,
        lat: widget.lat,
        lng: widget.lng,
        title: 'ODO.UZ',
      );
      if (mounted) {
        setState(() {
          _isMapReady = true;
        });
      }
    } catch (e) {
      print('❌ Ошибка создания карты: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return _placeholder();
    }

    if (_initializationError) {
      return _errorPlaceholder();
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
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      ),
    );
  }

  Widget _placeholder() {
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

  Widget _errorPlaceholder() {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
      ),
      child: const Center(
        child: Text(
          'Не удалось загрузить карту',
          style: TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
