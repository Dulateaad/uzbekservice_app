import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/design_system_button.dart';

class AddressScreen extends ConsumerStatefulWidget {
  final String specialistId;

  const AddressScreen({
    super.key,
    required this.specialistId,
  });

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  late TextEditingController _addressController;
  late TextEditingController _commentController;
  Map<String, double>? _currentLocation;

  @override
  void initState() {
    super.initState();
    final bookingState = ref.read(bookingProvider(widget.specialistId));
    _addressController = TextEditingController(text: bookingState.addressLine.isNotEmpty ? bookingState.addressLine : 'ул. Амира Темура, 15, Ташкент');
    _commentController = TextEditingController(text: bookingState.additionalNote ?? '');
    _currentLocation = bookingState.location;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider(widget.specialistId).notifier).setAddress(_addressController.text);
      ref.read(bookingProvider(widget.specialistId).notifier).setAdditionalNote(_commentController.text.isEmpty ? null : _commentController.text);
      if (_currentLocation != null) {
        ref.read(bookingProvider(widget.specialistId).notifier).setLocation(_currentLocation);
      }
    });

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    // TODO: integrate real geolocation
    final fakeLocation = {'lat': 41.2995, 'lng': 69.2401};
    setState(() {
      _currentLocation = fakeLocation;
    });
    ref.read(bookingProvider(widget.specialistId).notifier).setLocation(fakeLocation);
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider(widget.specialistId));
    final bookingNotifier = ref.read(bookingProvider(widget.specialistId).notifier);
    final canProceed = bookingState.addressLine.isNotEmpty;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Адрес'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Хлебные крошки
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Row(
              children: const [
                _Breadcrumb(text: 'Шаг 3 из 4', isActive: true),
                SizedBox(width: AppConstants.spacingSM),
                _Breadcrumb(text: 'Подтверждение'),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMiniMap(),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildAddressField(onChanged: bookingNotifier.setAddress),
                  const SizedBox(height: AppConstants.spacingLG),
                  _buildCommentField(onChanged: bookingNotifier.setAdditionalNote),
                  const SizedBox(height: AppConstants.spacingLG),
                  _buildMyLocationButton(),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(AppConstants.spacingLG),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusXL),
                topRight: Radius.circular(AppConstants.radiusXL),
              ),
              border: Border.all(
                color: AppConstants.borderColor,
                width: 1,
              ),
            ),
            child: SafeArea(
              child: DesignSystemButton(
                text: 'Далее',
                onPressed: canProceed
                    ? () {
                        bookingNotifier.setAddress(_addressController.text.trim());
                        bookingNotifier.setAdditionalNote(_commentController.text.trim().isEmpty ? null : _commentController.text.trim());
                        context.go('/home/booking/confirmation/${widget.specialistId}');
                      }
                    : null,
                type: ButtonType.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: AppConstants.borderColor,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: AppConstants.primaryColor,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Карта будет доступна в следующей версии',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_currentLocation != null)
            const Positioned(
              top: 80,
              left: 150,
              child: _LocationPin(),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressField({required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Адрес',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Введите адрес',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: AppConstants.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: AppConstants.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: AppConstants.primaryColor),
            ),
            filled: true,
            fillColor: AppConstants.surfaceColor,
          ),
          onChanged: (value) => onChanged(value.trim()),
        ),
      ],
    );
  }

  Widget _buildCommentField({required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Комментарий к адресу (необязательно)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Например: домофон не работает, звонить по телефону',
            prefixIcon: const Icon(Icons.comment_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: AppConstants.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: AppConstants.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide(color: AppConstants.primaryColor),
            ),
            filled: true,
            fillColor: AppConstants.surfaceColor,
          ),
          onChanged: (value) => onChanged(value.trim().isEmpty ? null : value.trim()),
        ),
      ],
    );
  }

  Widget _buildMyLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _getCurrentLocation,
        icon: const Icon(Icons.my_location),
        label: const Text('Использовать мою локацию'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
          side: BorderSide(color: AppConstants.primaryColor),
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  final String text;
  final bool isActive;

  const _Breadcrumb({
    required this.text,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSM,
        vertical: AppConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppConstants.primaryColor : AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
        border: Border.all(
          color: isActive ? AppConstants.primaryColor : AppConstants.borderColor,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AppConstants.primaryContrastColor : AppConstants.textSecondary,
        ),
      ),
    );
  }
}

class _LocationPin extends StatelessWidget {
  const _LocationPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
    );
  }
}
