import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _rangeStart = DateTime.now();
  DateTime? _rangeEnd;

  // Тестовые данные для расписания
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime.now(): [
      {
        'id': '1',
        'title': 'Ремонт крана - Азиз Ахмедов',
        'time': '10:00',
        'duration': 120,
        'status': 'confirmed',
        'client': 'Азиз Ахмедов',
        'address': 'Ташкент, Чилонзар, ул. Навои 15',
        'phone': '+998 90 123 45 67',
        'price': 150000,
      },
      {
        'id': '2',
        'title': 'Установка розетки - Марина Петрова',
        'time': '14:00',
        'duration': 90,
        'status': 'pending',
        'client': 'Марина Петрова',
        'address': 'Ташкент, Мирзо-Улугбек, ул. Университетская 25',
        'phone': '+998 90 234 56 78',
        'price': 200000,
      },
    ],
    DateTime.now().add(const Duration(days: 1)): [
      {
        'id': '3',
        'title': 'Генеральная уборка - Ольга Козлова',
        'time': '09:00',
        'duration': 240,
        'status': 'confirmed',
        'client': 'Ольга Козлова',
        'address': 'Ташкент, Шайхантахур, ул. Амира Темура 100',
        'phone': '+998 90 345 67 89',
        'price': 80000,
      },
    ],
    DateTime.now().add(const Duration(days: 2)): [
      {
        'id': '4',
        'title': 'Ремонт мебели - Сергей Иванов',
        'time': '11:00',
        'duration': 180,
        'status': 'confirmed',
        'client': 'Сергей Иванов',
        'address': 'Ташкент, Сергели, ул. Сергели 50',
        'phone': '+998 90 456 78 90',
        'price': 180000,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = DateTime.now();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarView(),
                _buildListView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppConstants.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Расписание',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.today, color: AppConstants.primaryColor),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppConstants.textPrimary),
          onPressed: _showSettings,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppConstants.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Календарь'),
          Tab(text: 'Список'),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildCalendar(),
            _buildEventList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppConstants.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<Map<String, dynamic>>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: AppConstants.textSecondary),
          holidayTextStyle: TextStyle(color: AppConstants.textSecondary),
          defaultTextStyle: const TextStyle(color: AppConstants.textPrimary),
          selectedTextStyle: const TextStyle(color: Colors.white),
          todayTextStyle: TextStyle(color: AppConstants.primaryColor),
          selectedDecoration: BoxDecoration(
            color: AppConstants.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppConstants.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
          formatButtonTextStyle: const TextStyle(color: Colors.white),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppConstants.primaryColor,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppConstants.primaryColor,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay ?? DateTime.now());
    
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return _buildEventCard(events[index], index);
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                border: Border.all(
                  color: _getStatusColor(event['status'] as String),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(event['status'] as String).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        ),
                        child: Icon(
                          _getStatusIcon(event['status'] as String),
                          color: _getStatusColor(event['status'] as String),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event['address'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            event['time'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(event['status'] as String),
                            ),
                          ),
                          Text(
                            '${event['duration']} мин',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatCurrency(event['price'] as double)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      _buildActionButtons(event),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> event) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _callClient(event),
          icon: const Icon(Icons.call, color: AppConstants.primaryColor),
          tooltip: 'Позвонить',
        ),
        IconButton(
          onPressed: () => _chatWithClient(event),
          icon: const Icon(Icons.chat, color: AppConstants.primaryColor),
          tooltip: 'Написать',
        ),
        IconButton(
          onPressed: () => _showEventDetails(event),
          icon: const Icon(Icons.info, color: AppConstants.textSecondary),
          tooltip: 'Подробнее',
        ),
      ],
    );
  }

  Widget _buildListView() {
    final allEvents = <Map<String, dynamic>>[];
    _events.values.forEach((events) => allEvents.addAll(events));
    allEvents.sort((a, b) => _parseTime(a['time'] as String).compareTo(_parseTime(b['time'] as String)));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: allEvents.length,
          itemBuilder: (context, index) {
            return _buildEventCard(allEvents[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: AppConstants.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'Нет запланированных событий',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'На выбранную дату нет запланированных встреч',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppConstants.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _addNewEvent,
      backgroundColor: AppConstants.primaryColor,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Добавить',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return AppConstants.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}М сум';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}К сум';
    } else {
      return '${amount.toInt()} сум';
    }
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  void _callClient(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Звонок ${event['client']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _chatWithClient(Map<String, dynamic> event) {
    context.push('/chat/event_${event['id']}');
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Клиент:', event['client'] as String),
            _buildDetailRow('Время:', event['time'] as String),
            _buildDetailRow('Длительность:', '${event['duration']} минут'),
            _buildDetailRow('Адрес:', event['address'] as String),
            _buildDetailRow('Телефон:', event['phone'] as String),
            _buildDetailRow('Цена:', _formatCurrency(event['price'] as double)),
            _buildDetailRow('Статус:', _getStatusText(event['status'] as String)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          DesignSystemButton(
            text: 'Редактировать',
            onPressed: () {
              Navigator.pop(context);
              _editEvent(event);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Подтвержден';
      case 'pending':
        return 'Ожидает подтверждения';
      case 'cancelled':
        return 'Отменен';
      case 'completed':
        return 'Завершен';
      default:
        return status;
    }
  }

  void _addNewEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Добавление нового события в разработке'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editEvent(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Редактирование события: ${event['title']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Настройки расписания',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingOption('Рабочие часы', Icons.access_time, () {}),
              _buildSettingOption('Уведомления', Icons.notifications, () {}),
              _buildSettingOption('Автоматическое планирование', Icons.auto_awesome, () {}),
              _buildSettingOption('Экспорт расписания', Icons.download, () {}),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
