import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SpecialistCard extends StatelessWidget {
  final String name;
  final String? category;
  final String? location;
  final double? rating;
  final int? reviewCount;
  final String? avatarUrl;
  final bool isFeatured;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const SpecialistCard({
    super.key,
    required this.name,
    this.category,
    this.location,
    this.rating,
    this.reviewCount,
    this.avatarUrl,
    this.isFeatured = false,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        splashColor: AppConstants.primaryColor.withOpacity(0.1),
        highlightColor: AppConstants.primaryColor.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: isFeatured
                ? LinearGradient(
                    colors: [
                      AppConstants.surfaceColor,
                      AppConstants.secondaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isFeatured ? null : AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            border: Border.all(
              color: isFeatured
                  ? AppConstants.secondaryColor
                  : AppConstants.borderColor.withOpacity(0.5),
              width: isFeatured ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isFeatured
                    ? AppConstants.secondaryColor.withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: isFeatured ? 20 : 12,
                offset: const Offset(0, 6),
                spreadRadius: isFeatured ? 2 : 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
          child: Row(
            children: [
              // Avatar with enhanced design
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLG + 2),
                      gradient: isFeatured
                          ? LinearGradient(
                              colors: [
                                AppConstants.secondaryColor.withOpacity(0.3),
                                AppConstants.primaryColor.withOpacity(0.3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      border: Border.all(
                        color: isFeatured
                            ? AppConstants.secondaryColor.withOpacity(0.5)
                            : AppConstants.borderColor,
                        width: isFeatured ? 2.5 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isFeatured
                              ? AppConstants.secondaryColor.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLG),
                      child: avatarUrl != null
                          ? Image.network(
                              avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildAvatarPlaceholder();
                              },
                            )
                          : _buildAvatarPlaceholder(),
                    ),
                  ),
                  if (isFeatured)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: AppConstants.secondaryGradient,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusRound),
                          border: Border.all(
                            color: AppConstants.surfaceColor,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppConstants.secondaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: AppConstants.secondaryContrastColor,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: AppConstants.spacingMD),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textPrimary,
                        fontFamily: AppConstants.fontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppConstants.spacingXS),

                    // Category
                    if (category != null)
                      Text(
                        category!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppConstants.textSecondary,
                          fontFamily: AppConstants.fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: AppConstants.spacingXS),

                    // Location
                    if (location != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppConstants.textSecondary,
                          ),
                          const SizedBox(width: AppConstants.spacingXS),
                          Expanded(
                            child: Text(
                              location!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.textSecondary,
                                fontFamily: AppConstants.fontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: AppConstants.spacingSM),

                    // Rating
                    if (rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppConstants.warningColor,
                          ),
                          const SizedBox(width: AppConstants.spacingXS),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimary,
                              fontFamily: AppConstants.fontFamily,
                            ),
                          ),
                          if (reviewCount != null) ...[
                            const SizedBox(width: AppConstants.spacingXS),
                            Text(
                              '($reviewCount)',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.textSecondary,
                                fontFamily: AppConstants.fontFamily,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),

              // Book Button with enhanced design
              if (onBook != null)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusRound),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onBook,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppConstants.primaryContrastColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppConstants.borderColor,
      child: Icon(
        Icons.person,
        color: AppConstants.textSecondary,
        size: 32,
      ),
    );
  }
}
