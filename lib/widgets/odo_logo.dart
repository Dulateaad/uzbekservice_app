import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class OdoLogo extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;

  const OdoLogo({
    super.key,
    this.width = 120,
    this.height = 60,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.jpg',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback на старый текстовый логотип, если изображение не загрузится
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppConstants.secondaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ODO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: AppConstants.primaryColor,
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              Text(
                '.UZ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
