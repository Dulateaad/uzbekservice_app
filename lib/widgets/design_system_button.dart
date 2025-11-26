import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum ButtonType { primary, secondary, accent, ghost, icon }

class DesignSystemButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final ButtonType type;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;

  const DesignSystemButton({
    super.key,
    this.text,
    this.icon,
    this.type = ButtonType.primary,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
  }) : assert(text != null || icon != null, 'Either text or icon must be provided');

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    Widget button;
    
    switch (type) {
      case ButtonType.primary:
        button = _buildPrimaryButton(isDisabled);
        break;
      case ButtonType.secondary:
        button = _buildSecondaryButton(isDisabled);
        break;
      case ButtonType.accent:
        button = _buildAccentButton(isDisabled);
        break;
      case ButtonType.ghost:
        button = _buildGhostButton(isDisabled);
        break;
      case ButtonType.icon:
        button = _buildIconButton(isDisabled);
        break;
    }

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    } else if (width != null) {
      button = SizedBox(
        width: width,
        child: button,
      );
    }

    return button;
  }

  Widget _buildPrimaryButton(bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled 
            ? AppConstants.borderColor 
            : AppConstants.primaryColor,
        foregroundColor: isDisabled 
            ? AppConstants.textDisabledColor 
            : AppConstants.primaryContrastColor,
        elevation: isDisabled ? 0 : 4,
        shadowColor: AppConstants.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: Size(0, height ?? 56),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isDisabled 
            ? AppConstants.borderColor 
            : AppConstants.surfaceColor,
        foregroundColor: isDisabled 
            ? AppConstants.textDisabledColor 
            : AppConstants.primaryColor,
        side: BorderSide(
          color: isDisabled 
              ? AppConstants.borderColor 
              : AppConstants.primaryColor, 
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: Size(0, height ?? 56),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildAccentButton(bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled 
            ? AppConstants.borderColor 
            : AppConstants.secondaryColor,
        foregroundColor: isDisabled 
            ? AppConstants.textDisabledColor 
            : AppConstants.secondaryContrastColor,
        elevation: isDisabled ? 0 : 4,
        shadowColor: AppConstants.secondaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: Size(0, height ?? 56),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildGhostButton(bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: isDisabled 
            ? AppConstants.textDisabledColor 
            : AppConstants.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        minimumSize: Size(0, height ?? 48),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildIconButton(bool isDisabled) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDisabled 
            ? AppConstants.borderColor 
            : AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDisabled 
                            ? AppConstants.textDisabledColor 
                            : AppConstants.textSecondary,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: isDisabled 
                        ? AppConstants.textDisabledColor 
                        : AppConstants.textSecondary,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.primary || type == ButtonType.accent
                ? AppConstants.primaryContrastColor
                : AppConstants.primaryColor,
          ),
        ),
      );
    }

    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppConstants.spacingSM),
          Text(
            text!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ],
      );
    } else if (icon != null) {
      return Icon(icon, size: 20);
    } else {
      return Text(
        text!,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: AppConstants.fontFamily,
        ),
      );
    }
  }
}
