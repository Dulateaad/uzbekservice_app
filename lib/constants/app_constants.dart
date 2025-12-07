import 'package:flutter/material.dart';

class AppConstants {
  // Brand Colors - Primary (Sky Blue) - Enhanced
  static const Color primaryColor = Color(0xFF0EA5E9); // Sky Blue
  static const Color primaryLightColor = Color(0xFF38BDF8);
  static const Color primaryDarkColor = Color(0xFF0284C7);
  static const Color primaryContrastColor = Color(0xFFFFFFFF);
  
  // Brand Colors - Secondary (Lime Green) - Enhanced
  static const Color secondaryColor = Color(0xFF84CC16); // Lime Green
  static const Color secondaryLightColor = Color(0xFFA3E635);
  static const Color secondaryDarkColor = Color(0xFF65A30D);
  static const Color secondaryContrastColor = Color(0xFFFFFFFF);
  
  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF84CC16), Color(0xFF65A30D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFD1D5DB);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textDisabledColor = Color(0xFF9CA3AF);
  
  // Semantic Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // Category Colors
  static const Color categoryBarberColor = Color(0xFF8B5CF6);
  static const Color categoryNannyColor = Color(0xFFEC4899);
  static const Color categoryHandymanColor = Color(0xFFF97316);
  static const Color categoryConstructionColor = Color(0xFF14B8A6);
  static const Color categoryMedicalColor = Color(0xFFEF4444);
  static const Color categoryOtherColor = Color(0xFF6B7280);
  static const Color categoryPlumberColor = Color(0xFF0891B2);
  static const Color categoryApplianceColor = Color(0xFF7C3AED);
  static const Color categoryHousekeeperColor = Color(0xFFDB2777);
  static const Color categoryTutorColor = Color(0xFF2563EB);
  static const Color categoryPsychologistColor = Color(0xFF059669);
  static const Color categoryMovingColor = Color(0xFFEA580C);
  static const Color categoryElectricianColor = Color(0xFFCA8A04);
  
  // Spacing (Design System)
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius (Design System)
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 999.0;
  
  // Typography (Design System)
  static const String fontFamily = 'SF Pro Display, -apple-system, Roboto, sans-serif';
  static const String fontFamilySecondary = 'SF Pro Text, -apple-system, Roboto, sans-serif';
  
  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeTitle = 28.0;
  
  // API
  static const String baseUrl = 'https://api.uzbekservice.uz/api/v1';
  static const String devBaseUrl = 'http://localhost:3000/api/v1';
  
  // App Info
  static const String appName = 'ODO.UZ';
  static const String appVersion = '1.0.0-MVP';
  
  // Categories (Design System)
  static const List<Map<String, dynamic>> serviceCategories = [
    {
      'id': 'barber',
      'name': 'Барберы',
      'icon': Icons.content_cut,
      'color': categoryBarberColor,
      'emoji': '✂️',
      'description': 'Стрижки, укладки, бритьё',
    },
    {
      'id': 'plumber',
      'name': 'Сантехники',
      'icon': Icons.plumbing,
      'color': categoryPlumberColor,
      'emoji': '🔧',
      'description': 'Ремонт труб, установка сантехники',
    },
    {
      'id': 'electrician',
      'name': 'Электрики',
      'icon': Icons.electrical_services,
      'color': categoryElectricianColor,
      'emoji': '⚡',
      'description': 'Проводка, розетки, освещение',
    },
    {
      'id': 'appliance_repair',
      'name': 'Ремонт техники',
      'icon': Icons.home_repair_service,
      'color': categoryApplianceColor,
      'emoji': '🔌',
      'description': 'Ремонт бытовой техники',
    },
    {
      'id': 'construction',
      'name': 'Строительство и ремонт',
      'icon': Icons.construction,
      'color': categoryConstructionColor,
      'emoji': '🏗️',
      'description': 'Ремонт квартир, домов',
    },
    {
      'id': 'housekeeper',
      'name': 'Домработницы',
      'icon': Icons.cleaning_services,
      'color': categoryHousekeeperColor,
      'emoji': '🧹',
      'description': 'Уборка, глажка, готовка',
    },
    {
      'id': 'nanny',
      'name': 'Няни',
      'icon': Icons.child_care,
      'color': categoryNannyColor,
      'emoji': '👶',
      'description': 'Уход за детьми',
    },
    {
      'id': 'tutor',
      'name': 'Репетиторы',
      'icon': Icons.school,
      'color': categoryTutorColor,
      'emoji': '📚',
      'description': 'Обучение, подготовка к экзаменам',
    },
    {
      'id': 'psychologist',
      'name': 'Психологи',
      'icon': Icons.psychology,
      'color': categoryPsychologistColor,
      'emoji': '🧠',
      'description': 'Консультации, терапия',
    },
    {
      'id': 'moving',
      'name': 'Услуги переезда',
      'icon': Icons.local_shipping,
      'color': categoryMovingColor,
      'emoji': '🚚',
      'description': 'Грузчики, перевозка мебели',
    },
    {
      'id': 'handyman',
      'name': 'Мастера на все руки',
      'icon': Icons.build,
      'color': categoryHandymanColor,
      'emoji': '🛠️',
      'description': 'Мелкий ремонт, сборка мебели',
    },
  ];
  
  // Order Status
  static const Map<String, String> orderStatuses = {
    'pending': 'Ожидает подтверждения',
    'accepted': 'Принят',
    'in_progress': 'В работе',
    'completed': 'Завершен',
    'reviewed': 'Отзыв оставлен',
    'cancelled': 'Отменен',
  };
  
  // User Types
  static const String userTypeClient = 'client';
  static const String userTypeSpecialist = 'specialist';
  static const String userTypeAdmin = 'admin';
}