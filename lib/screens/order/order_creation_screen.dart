import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class OrderCreationScreen extends ConsumerStatefulWidget {
  final String specialistId;
  
  const OrderCreationScreen({
    super.key,
    required this.specialistId,
  });

  @override
  ConsumerState<OrderCreationScreen> createState() => _OrderCreationScreenState();
}

class _OrderCreationScreenState extends ConsumerState<OrderCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _selectedHours = 2;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(orderProvider.notifier).createOrder(
        specialistId: widget.specialistId,
        title: _titleController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        latitude: 41.2995, // Примерные координаты Ташкента
        longitude: 69.2401,
        scheduledDate: _selectedDate,
        estimatedHours: _selectedHours,
        clientNotes: _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заказ создан успешно!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания заказа: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Создание заказа'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок заказа
              CustomTextField(
                controller: _titleController,
                labelText: 'Название услуги',
                hintText: 'Например: Стрижка и бритье',
                prefixIcon: const Icon(Icons.title),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название услуги';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Описание
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Описание услуги',
                hintText: 'Подробно опишите, что вам нужно',
                maxLines: 3,
                prefixIcon: const Icon(Icons.description),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите описание услуги';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Адрес
              CustomTextField(
                controller: _addressController,
                labelText: 'Адрес',
                hintText: 'Укажите точный адрес',
                prefixIcon: const Icon(Icons.location_on),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите адрес';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Дата и время
              const Text(
                'Дата и время',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(
                              '${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Продолжительность
              const Text(
                'Продолжительность (часы)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  IconButton(
                    onPressed: _selectedHours > 1
                        ? () => setState(() => _selectedHours--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_selectedHours ч',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectedHours < 8
                        ? () => setState(() => _selectedHours++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Дополнительные заметки
              CustomTextField(
                controller: _notesController,
                labelText: 'Дополнительные заметки (необязательно)',
                hintText: 'Любая дополнительная информация',
                maxLines: 2,
                prefixIcon: const Icon(Icons.note),
              ),
              
              const SizedBox(height: 24),
              
              // Итоговая стоимость
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Итого:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(_selectedHours * 50000).toStringAsFixed(0)} сум',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Кнопка создания заказа
              CustomButton(
                text: 'Создать заказ',
                onPressed: _isLoading ? null : _createOrder,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
