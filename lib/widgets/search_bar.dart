import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class DesignSystemSearchBar extends StatefulWidget {
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const DesignSystemSearchBar({
    super.key,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<DesignSystemSearchBar> createState() => _DesignSystemSearchBarState();
}

class _DesignSystemSearchBarState extends State<DesignSystemSearchBar> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: _isFocused
              ? LinearGradient(
                  colors: [
                    AppConstants.surfaceColor,
                    AppConstants.primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: _isFocused ? null : AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: _isFocused 
              ? Border.all(
                  color: AppConstants.primaryColor,
                  width: 2.5,
                )
              : Border.all(
                  color: AppConstants.borderColor.withOpacity(0.5),
                  width: 1.5,
                ),
          boxShadow: _isFocused 
              ? [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: TextField(
          controller: _controller,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Поиск...',
            hintStyle: TextStyle(
              color: AppConstants.textHint,
              fontSize: 16,
              fontFamily: AppConstants.fontFamily,
            ),
            prefixIcon: widget.prefixIcon ?? Icon(
              Icons.search,
              color: _isFocused 
                  ? AppConstants.primaryColor 
                  : AppConstants.textSecondary,
              size: 20,
            ),
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingMD,
              horizontal: AppConstants.spacingMD,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textPrimary,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ),
    );
  }
}
