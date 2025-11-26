import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;
  final double height;
  final Duration autoScrollDuration;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.height = 180,
    this.autoScrollDuration = const Duration(seconds: 4),
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.banners.length <= 1) return;
    
    _timer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (_pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return _buildBannerCard(banner);
            },
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        _buildPageIndicators(),
      ],
    );
  }

  Widget _buildBannerCard(BannerItem banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSM),
      decoration: BoxDecoration(
        gradient: banner.gradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        child: Stack(
          children: [
            // Фоновое изображение или градиент
            if (banner.backgroundImage != null)
              Positioned.fill(
                child: Image.network(
                  banner.backgroundImage!,
                  fit: BoxFit.cover,
                ),
              ),
            
            // Контент баннера
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLG),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        if (banner.subtitle != null) ...[
                          const SizedBox(height: AppConstants.spacingSM),
                          Text(
                            banner.subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppConstants.spacingMD),
                        ElevatedButton(
                          onPressed: banner.onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppConstants.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingLG,
                              vertical: AppConstants.spacingSM,
                            ),
                          ),
                          child: Text(
                            banner.buttonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (banner.icon != null) ...[
                    const SizedBox(width: AppConstants.spacingMD),
                    Icon(
                      banner.icon,
                      size: 64,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    if (widget.banners.length <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.banners.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index 
                ? AppConstants.primaryColor 
                : AppConstants.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class BannerItem {
  final String title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final IconData? icon;
  final String? backgroundImage;

  const BannerItem({
    required this.title,
    this.subtitle,
    required this.buttonText,
    this.onTap,
    required this.gradient,
    this.icon,
    this.backgroundImage,
  });
}
