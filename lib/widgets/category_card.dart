import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CategoryCard extends StatelessWidget {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String? emoji;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.emoji,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL + 4),
          border: Border.all(
            color: isSelected 
                ? color
                : AppConstants.borderColor.withOpacity(0.5),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? color.withOpacity(0.25)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 6),
              spreadRadius: isSelected ? 1 : 0,
            ),
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.all(AppConstants.spacingSM),
        margin: const EdgeInsets.only(bottom: AppConstants.spacingXS),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container with enhanced design
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: emoji != null
                    ? Text(
                        emoji!,
                        style: const TextStyle(fontSize: 24),
                      )
                    : Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
              ),
            ),
            
            const SizedBox(height: AppConstants.spacingXS),
            
            // Category Name
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
                fontFamily: AppConstants.fontFamily,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}