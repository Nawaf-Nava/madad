import 'package:flutter/material.dart';
import '../../core/l10n/madad_localizations.dart';
import '../../core/theme/madad_theme.dart';
import '../../core/widgets/madad_ui.dart';
import 'qr_scanner_screen.dart';

class PaymentsScreen extends StatefulWidget {
  final String? initial;
  const PaymentsScreen({super.key, this.initial});
  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late int selected = switch (widget.initial) {
    'شحن رصيد' => 1,
    _ => 0,
  };
  static const options = [
    ('رمز QR', 'QR code'),
    ('شحن رصيد', 'Top up'),
    ('فواتير وخدمات', 'Bills and services'),
    ('بطاقة رقمية', 'Digital card'),
  ];
  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          title:
              Text(l10n.choose(ar: 'الدفع والشحن', en: 'Payments and top-up'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(ar: 'اختر الخدمة', en: 'Choose a service'),
            subtitle: l10n.choose(
                ar: 'خيارات واجهة فقط؛ لا يوجد مزود دفع متصل.',
                en: 'Interface options only; no payment provider is connected.'),
            icon: Icons.receipt_long_rounded,
          ),
          RadioGroup<int>(
            groupValue: selected,
            onChanged: (value) {
              if (value != null) setState(() => selected = value);
            },
            child: Column(
              children: [
                for (var index = 0; index < options.length; index++)
                  Card(
                    child: RadioListTile<int>(
                      value: index,
                      title: Text(l10n.choose(
                          ar: options[index].$1, en: options[index].$2)),
                      secondary: Icon(_icon(index), color: MadadColors.orange),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MadadNotice(
            message: l10n.choose(
              ar: 'الدفع والشحن غير متاحين دون مزود معتمد. لن يتم تسجيل نجاح أو خصم مبلغ هنا.',
              en: 'Payments and top-ups require an authorized provider. No success or charge will be recorded here.',
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _act,
            icon: Icon(
                selected == 0 ? Icons.qr_code_scanner : Icons.arrow_forward),
            label: Text(selected == 0
                ? l10n.choose(ar: 'فتح معاينة ماسح QR', en: 'Open QR preview')
                : l10n.choose(ar: 'متابعة', en: 'Continue')),
          ),
        ],
      ),
    );
  }

  IconData _icon(int index) => switch (index) {
        0 => Icons.qr_code_2,
        1 => Icons.phone_android,
        3 => Icons.credit_card,
        _ => Icons.receipt_long,
      };

  void _act() {
    final l10n = MadadLocalizations.of(context);
    if (selected == 0) {
      Navigator.push(context, madadPageRoute(const QrScannerScreen()));
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            l10n.choose(ar: options[selected].$1, en: options[selected].$2)),
        content: Text(l10n.choose(
          ar: selected == 0
              ? 'معاينة الكاميرا غير متاحة في هذه النسخة. لم تتم قراءة رمز أو تنفيذ دفع.'
              : 'الخدمة غير متصلة؛ لم يتم إنشاء طلب أو تنفيذ عملية.',
          en: selected == 0
              ? 'Camera preview is unavailable in this build. No code was scanned and no payment was made.'
              : 'The service is not connected; no request or transaction was created.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.text('close')),
          ),
        ],
      ),
    );
  }
}
