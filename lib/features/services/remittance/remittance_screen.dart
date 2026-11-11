import 'package:flutter/material.dart';

import '../../../core/l10n/madad_localizations.dart';
import '../../../core/widgets/madad_ui.dart';

class RemittanceScreen extends StatefulWidget {
  const RemittanceScreen({super.key});
  @override
  State<RemittanceScreen> createState() => _RemittanceScreenState();
}

class _RemittanceScreenState extends State<RemittanceScreen> {
  int network = 0;
  static const networks = [
    ('الحازمي', 'Al Hazmi'),
    ('الامتياز', 'Al Imtiaz'),
    ('الإرسال السريع', 'Express'),
    ('الثقة', 'Al Thiqa'),
  ];
  final codeC = TextEditingController();
  final receiverC = TextEditingController();

  @override
  void dispose() {
    codeC.dispose();
    receiverC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(l10n.choose(ar: 'الحوالات والشبكات', en: 'Remittances'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(ar: 'استعلام الحوالة', en: 'Remittance lookup'),
            subtitle: l10n.choose(
                ar: 'يتطلب الاستعلام اتصالاً بالشبكة المعتمدة.',
                en: 'Lookup requires a connection to the authorized network.'),
            icon: Icons.send_rounded,
          ),
          MadadNotice(
              message: l10n.choose(
            ar: 'لا يتصل هذا النموذج بأي شبكة حوالات، ولم يتم البحث عن رقم حقيقي.',
            en: 'This form is not connected to a remittance network; no live lookup was made.',
          )),
          const SizedBox(height: 16),
          Text(l10n.choose(ar: 'شبكة الحوالات', en: 'Network'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: network,
            decoration: const InputDecoration(),
            items: [
              for (var index = 0; index < networks.length; index++)
                DropdownMenuItem(
                    value: index,
                    child: Text(l10n.choose(
                        ar: networks[index].$1, en: networks[index].$2)))
            ],
            onChanged: (v) => setState(() => network = v ?? network),
          ),
          const SizedBox(height: 16),
          TextField(
              controller: codeC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: l10n.choose(
                      ar: 'رقم الحوالة', en: 'Remittance reference'),
                  prefixIcon: const Icon(Icons.confirmation_number_outlined))),
          const SizedBox(height: 16),
          TextField(
              controller: receiverC,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: l10n.choose(
                      ar: 'هاتف المستلم أو الهوية',
                      en: 'Recipient phone or ID'),
                  prefixIcon: const Icon(Icons.badge_outlined))),
          const SizedBox(height: 24),
          FilledButton(
              onPressed: _search,
              child: Text(l10n.choose(
                  ar: 'التحقق من توفر الخدمة',
                  en: 'Check service availability'))),
        ],
      ),
    );
  }

  void _search() {
    final l10n = MadadLocalizations.of(context);
    if (codeC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.choose(
              ar: 'أدخل رقم الحوالة للمتابعة.',
              en: 'Enter a remittance reference to continue.'))));
      return;
    }
    showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
              title: Text(l10n.choose(
                  ar: 'الخدمة غير متاحة', en: 'Service unavailable')),
              content: Text(l10n.choose(
                  ar: 'لم يتم البحث عن رقم الحوالة؛ لا توجد شبكة متصلة.',
                  en: 'The reference was not looked up; no network is connected.')),
              actions: [
                FilledButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text(l10n.text('close')))
              ],
            ));
  }
}
