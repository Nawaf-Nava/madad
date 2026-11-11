import 'package:flutter/material.dart';

import '../../../core/l10n/madad_localizations.dart';
import '../../../core/widgets/madad_ui.dart';

class HadiahScreen extends StatefulWidget {
  const HadiahScreen({super.key});
  @override
  State<HadiahScreen> createState() => _HadiahScreenState();
}

class _HadiahScreenState extends State<HadiahScreen> {
  final recipient = TextEditingController();
  final amount = TextEditingController();
  final message = TextEditingController();
  int occasion = 0;
  static const occasions = [
    ('هدية عامة', 'General'),
    ('عيد ميلاد', 'Birthday'),
    ('مفاجأة نجاح', 'Congratulations'),
    ('تهنئة عيدية', 'Holiday greeting'),
    ('مناسبة خاصة', 'Special occasion'),
  ];

  @override
  void dispose() {
    recipient.dispose();
    amount.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.choose(ar: 'الهدايا', en: 'Gifts'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(ar: 'معاينة هدية', en: 'Gift preview'),
            subtitle: l10n.choose(
                ar: 'أدخل تفاصيل للمعاينة المحلية فقط.',
                en: 'Enter details for a local preview only.'),
            icon: Icons.card_giftcard_rounded,
          ),
          MadadNotice(
              message: l10n.choose(
            ar: 'لا يتم إرسال هدية أو خصم مبلغ في هذه المعاينة.',
            en: 'This preview does not send a gift or debit any amount.',
          )),
          const SizedBox(height: 16),
          Text(l10n.choose(ar: 'المناسبة', en: 'Occasion'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: occasion,
            decoration: const InputDecoration(),
            items: [
              for (var index = 0; index < occasions.length; index++)
                DropdownMenuItem(
                    value: index,
                    child: Text(l10n.choose(
                        ar: occasions[index].$1, en: occasions[index].$2)))
            ],
            onChanged: (v) => setState(() => occasion = v ?? occasion),
          ),
          const SizedBox(height: 16),
          TextField(
              controller: recipient,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: l10n.choose(
                      ar: 'رقم هاتف المستلم', en: 'Recipient phone'),
                  prefixIcon: const Icon(Icons.phone_outlined))),
          const SizedBox(height: 16),
          TextField(
              controller: amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: l10n.choose(
                      ar: 'قيمة الهدية (للمعاينة)',
                      en: 'Gift amount (preview)'),
                  suffixText: 'ر.ي')),
          const SizedBox(height: 16),
          TextField(
              controller: message,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: l10n.choose(ar: 'رسالة', en: 'Message'),
                  hintText: l10n.choose(
                      ar: 'اكتب رسالة للمعاينة',
                      en: 'Write a preview message'))),
          const SizedBox(height: 24),
          FilledButton(
              onPressed: _submit,
              child: Text(
                  l10n.choose(ar: 'معاينة التفاصيل', en: 'Preview details'))),
        ],
      ),
    );
  }

  void _submit() {
    final l10n = MadadLocalizations.of(context);
    if (recipient.text.trim().isEmpty || amount.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.choose(
              ar: 'أدخل رقم المستلم والمبلغ للمعاينة.',
              en: 'Enter a recipient and amount for the preview.'))));
      return;
    }
    showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
              title: Text(l10n.choose(ar: 'معاينة الهدية', en: 'Gift preview')),
              content: Text(l10n.choose(
                  ar: 'هذه معاينة محلية فقط للمستلم ${recipient.text} بقيمة ${amount.text} ر.ي. لم يتم إرسال هدية.',
                  en: 'This is a local preview for ${recipient.text}, amount ${amount.text} YER. No gift was sent.')),
              actions: [
                FilledButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text(l10n.text('close')))
              ],
            ));
  }
}
