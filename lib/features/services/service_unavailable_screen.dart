import 'package:flutter/material.dart';

import '../../core/l10n/madad_localizations.dart';
import '../../core/widgets/madad_ui.dart';

class ServiceUnavailableScreen extends StatelessWidget {
  const ServiceUnavailableScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: title,
            subtitle: l10n.choose(
              ar: 'معلومات الخدمة',
              en: 'Service information',
            ),
            icon: Icons.account_balance_outlined,
          ),
          SizedBox(
            height: 380,
            child: MadadEmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.choose(
                ar: 'الخدمة غير متاحة',
                en: 'Service unavailable',
              ),
              message: l10n.choose(
                ar: 'لا توجد بيانات خدمة متصلة في هذه النسخة. لم يتم إنشاء طلب أو تنفيذ عملية.',
                en: 'No connected service data is available in this build. No request or operation was created.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
