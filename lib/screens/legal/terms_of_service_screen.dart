import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Пользовательское соглашение'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Пользовательское соглашение',
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
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Используя приложение ODO.UZ, вы соглашаетесь с условиями настоящего Соглашения.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              context,
              '1. Общие положения',
              'Настоящее Пользовательское соглашение регулирует отношения между компанией ODO.UZ и пользователями мобильного приложения ODO.UZ. Приложение представляет собой платформу для поиска и заказа услуг специалистов в Узбекистане и Казахстане.',
            ),
            _buildSection(
              context,
              '2. Регистрация и учетная запись',
              'Для использования Приложения необходимо быть не младше 18 лет, иметь действующий номер телефона и создать учетную запись через OneID или номер телефона. Вы несете ответственность за конфиденциальность данных вашей учетной записи и все действия, совершенные под вашей учетной записью.',
            ),
            _buildSection(
              context,
              '3. Использование Сервиса',
              'Клиенты обязуются использовать Сервис только в законных целях, предоставлять достоверную информацию, своевременно оплачивать заказанные услуги и уважительно относиться к Специалистам.\n\nСпециалисты обязуются предоставлять достоверную информацию, выполнять заказы качественно и в срок, соблюдать договоренности с Клиентами.\n\nЗапрещается использовать Приложение для незаконной деятельности, размещать ложную информацию, нарушать права других пользователей.',
            ),
            _buildSection(
              context,
              '4. Заказы и оплата',
              'Клиент выбирает Специалиста и услуги, указывает дату, время и адрес, подтверждает заказ и производит оплату. Оплата производится через интегрированные платежные системы (Click, Payme). Мы не храним данные банковских карт. Клиент может отменить заказ до начала выполнения услуги.',
            ),
            _buildSection(
              context,
              '5. Ответственность',
              'Мы не несем ответственности за качество услуг, предоставляемых Специалистами, споры между Клиентами и Специалистами, ущерб, причиненный в результате использования услуг. Пользователи несут ответственность за свои действия в Приложении и соблюдение законодательства.',
            ),
            _buildSection(
              context,
              '6. Изменения в Соглашении',
              'Мы оставляем за собой право изменять настоящее Соглашение в любое время. О существенных изменениях мы уведомим пользователей через Приложение. Продолжение использования Сервиса после внесения изменений означает ваше согласие с новой версией Соглашения.',
            ),
            _buildSection(
              context,
              '7. Контактная информация',
              'ODO.UZ\nEmail: support@odo.uz\nТелефон: +998 (XX) XXX-XX-XX\nАдрес: Республика Узбекистан, г. Ташкент',
              isHighlighted: true,
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

