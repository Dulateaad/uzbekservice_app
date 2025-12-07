import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Политика конфиденциальности'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Политика конфиденциальности',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Последнее обновление: 2 декабря 2024 г.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Общие положения',
              'Настоящая Политика конфиденциальности определяет порядок обработки и защиты персональных данных пользователей мобильного приложения ODO.UZ (далее — «Приложение»), разработанного и управляемого компанией ODO.UZ (далее — «Мы», «Нас», «Наш»).\n\nИспользуя Приложение, вы соглашаетесь с условиями настоящей Политики конфиденциальности. Если вы не согласны с условиями, пожалуйста, не используйте Приложение.',
            ),
            _buildSection(
              context,
              '2. Собираемая информация',
              'Мы собираем следующие типы информации:\n\n• Персональные данные: имя, номер телефона, адрес электронной почты, адрес доставки\n• Данные профиля: фотография профиля, описание услуг (для специалистов), рейтинги и отзывы\n• Данные о местоположении: геолокационные данные для поиска ближайших специалистов\n• Данные об использовании: история заказов, предпочтения, взаимодействия с приложением\n• Технические данные: IP-адрес, тип устройства, операционная система, идентификаторы устройств\n• Данные платежей: информация о транзакциях (обрабатывается через платежные системы Click, Payme)',
            ),
            _buildSection(
              context,
              '3. Цели использования информации',
              'Мы используем собранную информацию для следующих целей:\n\n• Предоставление и улучшение услуг Приложения\n• Обработка заказов и управление транзакциями\n• Связь с пользователями по вопросам услуг и поддержки\n• Персонализация опыта использования Приложения\n• Отправка уведомлений о заказах и обновлениях\n• Обеспечение безопасности и предотвращение мошенничества\n• Соблюдение правовых обязательств\n• Проведение аналитики и улучшение функциональности',
            ),
            _buildSection(
              context,
              '4. Передача данных третьим лицам',
              'Мы можем передавать ваши данные следующим категориям получателей:\n\n• Платежные системы: Click, Payme — для обработки платежей\n• OneID: для аутентификации пользователей\n• Firebase (Google): для хранения данных, аналитики и push-уведомлений\n• Специалисты: базовая информация (имя, телефон) для выполнения заказов\n• Провайдеры услуг: хостинг, аналитика, поддержка клиентов\n• Правоохранительные органы: при наличии законных требований\n\nМы не продаем ваши персональные данные третьим лицам. Все передачи данных осуществляются в соответствии с требованиями законодательства Республики Узбекистан.',
            ),
            _buildSection(
              context,
              '5. Безопасность данных',
              'Мы применяем современные технические и организационные меры для защиты ваших персональных данных:\n\n• Шифрование данных при передаче (HTTPS/TLS)\n• Безопасное хранение данных в Firebase\n• Ограничение доступа к данным только авторизованным сотрудникам\n• Регулярное обновление систем безопасности\n• Мониторинг и предотвращение несанкционированного доступа',
            ),
            _buildSection(
              context,
              '6. Ваши права',
              'Вы имеете право:\n\n• Получать информацию о ваших персональных данных\n• Требовать исправления неточных данных\n• Требовать удаления ваших данных (право на забвение)\n• Ограничивать обработку ваших данных\n• Отозвать согласие на обработку данных\n• Подать жалобу в уполномоченный орган по защите персональных данных\n\nДля осуществления ваших прав свяжитесь с нами по адресу: support@odo.uz',
            ),
            _buildSection(
              context,
              '7. Хранение данных',
              'Мы храним ваши персональные данные в течение срока, необходимого для целей, указанных в настоящей Политике, или в течение срока, установленного законодательством. После истечения срока хранения данные удаляются или обезличиваются.',
            ),
            _buildSection(
              context,
              '8. Изменения в Политике конфиденциальности',
              'Мы оставляем за собой право вносить изменения в настоящую Политику конфиденциальности. О существенных изменениях мы уведомим вас через Приложение или по электронной почте. Продолжение использования Приложения после внесения изменений означает ваше согласие с новой версией Политики.',
            ),
            _buildSection(
              context,
              '9. Контактная информация',
              'ODO.UZ\nEmail: support@odo.uz\nТелефон: +998 (XX) XXX-XX-XX\nАдрес: Республика Узбекистан, г. Ташкент',
              isHighlighted: true,
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: 'support@odo.uz'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email скопирован в буфер обмена'),
                    ),
                  );
                },
                icon: const Icon(Icons.email),
                label: const Text('Скопировать email поддержки'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content, {
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppConstants.primaryColor.withValues(alpha: 0.1)
            : AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: isHighlighted
              ? AppConstants.primaryColor
              : AppConstants.borderColor,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}

