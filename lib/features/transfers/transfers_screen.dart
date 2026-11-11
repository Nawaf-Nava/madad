import 'package:flutter/material.dart';
import '../../core/l10n/madad_localizations.dart';
import '../../core/widgets/madad_ui.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});
  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  final form = GlobalKey<FormState>();
  final phone = TextEditingController();
  final amount = TextEditingController();
  final note = TextEditingController();
  int type = 0;
  static const _types = [
    ('إلى محفظة مَدَد', 'To MADAD wallet'),
    ('إلى شخص', 'To a person'),
    ('تحويل خارجي', 'External transfer'),
  ];
  @override
  void dispose() {
    phone.dispose();
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('transfer'))),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            MadadPageHeader(
              title: l10n.text('transfer'),
              subtitle: l10n.choose(
                  ar: 'اختر نوع التحويل وأدخل التفاصيل للمراجعة.',
                  en: 'Choose a transfer type and enter details for review.'),
              icon: Icons.swap_horiz_rounded,
            ),
            MadadSectionTitle(
                l10n.choose(ar: 'نوع التحويل', en: 'Transfer type')),
            DropdownButtonFormField<int>(
              initialValue: type,
              decoration: const InputDecoration(),
              items: [
                for (var index = 0; index < _types.length; index++)
                  DropdownMenuItem(
                    value: index,
                    child: Text(l10n.choose(
                        ar: _types[index].$1, en: _types[index].$2)),
                  ),
              ],
              onChanged: (value) => setState(() => type = value ?? type),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.text('phoneNumber'),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (value) => (value == null || value.trim().length < 7)
                  ? l10n.choose(
                      ar: 'أدخل رقم هاتف صالحاً',
                      en: 'Enter a valid phone number')
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.choose(ar: 'المبلغ', en: 'Amount'),
                suffixText: 'ر.ي',
              ),
              validator: (value) {
                final number = num.tryParse(value ?? '');
                return number == null || number <= 0
                    ? l10n.choose(
                        ar: 'أدخل مبلغاً صالحاً', en: 'Enter a valid amount')
                    : null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: note,
              maxLength: 80,
              decoration: InputDecoration(
                labelText:
                    l10n.choose(ar: 'ملاحظة (اختياري)', en: 'Note (optional)'),
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 8),
            MadadNotice(
              icon: Icons.lock_outline_rounded,
              message: l10n.choose(
                ar: 'معاينة فقط: لن يتم إرسال أموال. التحويلات تتطلب مزوداً مالياً معتمداً.',
                en: 'Review only: no money will be sent. Transfers require an authorized financial provider.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _continue,
              child: Text(
                  l10n.choose(ar: 'مراجعة البيانات', en: 'Review details')),
            ),
          ],
        ),
      ),
    );
  }

  void _continue() {
    if (!form.currentState!.validate()) return;
    final l10n = MadadLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, 24 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.choose(ar: 'مراجعة التحويل', en: 'Review transfer'),
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 14),
            Text(
                '${l10n.choose(ar: 'النوع', en: 'Type')}: ${l10n.choose(ar: _types[type].$1, en: _types[type].$2)}'),
            Text(
                '${l10n.choose(ar: 'المستفيد', en: 'Recipient')}: ${phone.text}'),
            Text(
                '${l10n.choose(ar: 'المبلغ', en: 'Amount')}: ${amount.text} ر.ي'),
            if (note.text.isNotEmpty)
              Text('${l10n.choose(ar: 'الملاحظة', en: 'Note')}: ${note.text}'),
            const SizedBox(height: 12),
            MadadNotice(
                message: l10n.choose(
                    ar: 'لم يتم تنفيذ أي عملية؛ هذه معاينة فقط.',
                    en: 'No operation was executed; this is a preview only.')),
            const SizedBox(height: 18),
            FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.text('close'))),
          ],
        ),
      ),
    );
  }
}
