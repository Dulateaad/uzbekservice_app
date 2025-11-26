import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_constants.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppConstants.borderColor,
      highlightColor: AppConstants.borderColor.withOpacity(0.5),
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.radiusMD),
        ),
      ),
    );
  }
}

class ShimmerSpecialistCard extends StatelessWidget {
  const ShimmerSpecialistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: AppConstants.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ShimmerLoading(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          const SizedBox(width: AppConstants.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                const SizedBox(height: AppConstants.spacingSM),
                ShimmerLoading(
                  width: 120,
                  height: 14,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                const SizedBox(height: AppConstants.spacingSM),
                ShimmerLoading(
                  width: 100,
                  height: 14,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingMD),
          ShimmerLoading(
            width: 52,
            height: 52,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          ),
        ],
      ),
    );
  }
}

class ShimmerCategoryCard extends StatelessWidget {
  const ShimmerCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppConstants.spacingSM),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: AppConstants.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ShimmerLoading(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          const SizedBox(height: AppConstants.spacingXS),
          ShimmerLoading(
            width: 60,
            height: 12,
            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
          ),
        ],
      ),
    );
  }
}

