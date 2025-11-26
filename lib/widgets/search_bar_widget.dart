import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SearchBarWidget extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const SearchBarWidget({
    super.key,
    this.hintText,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText ?? 'Поиск специалистов...',
          hintStyle: TextStyle(
            color: AppConstants.textHint,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppConstants.textSecondary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.filter_list,
              color: AppConstants.textSecondary,
            ),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}