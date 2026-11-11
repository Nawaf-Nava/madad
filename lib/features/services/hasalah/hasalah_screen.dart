import 'package:flutter/material.dart';

import '../../../core/l10n/madad_localizations.dart';
import '../../../core/theme/madad_theme.dart';
import '../../../core/widgets/madad_ui.dart';

class HasalahScreen extends StatefulWidget {
  const HasalahScreen({super.key});
  @override
  State<HasalahScreen> createState() => _HasalahScreenState();
}

class _HasalahScreenState extends State<HasalahScreen> {
  final boxes = <Map<String, dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(l10n.choose(ar: 'أهداف الادخار', en: 'Savings goals'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(ar: 'أهداف الادخار', en: 'Savings goals'),
            subtitle: l10n.choose(
                ar: 'الأهداف المسجلة هنا محلية ولا تمثل أموالاً مودعة.',
                en: 'Goals here are local and do not represent deposited funds.'),
            icon: Icons.savings_outlined,
          ),
          MadadNotice(
              message: l10n.choose(
            ar: 'لا توجد خدمة ادخار متصلة. لا يتم إيداع أو تحويل أي مبلغ إلى هدف.',
            en: 'No savings service is connected. No amount is deposited or transferred to a goal.',
          )),
          if (boxes.isEmpty)
            SizedBox(
              height: 230,
              child: MadadEmptyState(
                icon: Icons.savings_outlined,
                title: l10n.choose(
                    ar: 'لا توجد أهداف محفوظة', en: 'No saved goals'),
                message: l10n.choose(
                    ar: 'يمكنك إضافة وصف وهدف محلي للمعاينة دون رصيد.',
                    en: 'Add a local goal label for preview; no balance is attached.'),
              ),
            ),
          ...boxes.map((b) => Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                            backgroundColor: MadadColors.orangePale,
                            child: Icon(b['icon'] as IconData,
                                color: MadadColors.orange)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(b['title'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16))),
                        Text(l10n.choose(ar: 'غير ممول', en: 'Not funded'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: MadadColors.textSecondary)),
                      ]),
                      const SizedBox(height: 14),
                      const LinearProgressIndicator(value: 0),
                      const SizedBox(height: 8),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${l10n.choose(ar: 'الهدف المحلي', en: 'Local target')}: ${b['target']} ر.ي',
                                style: const TextStyle(
                                    fontSize: 12, color: MadadColors.muted)),
                            Text(l10n.choose(ar: 'محلي', en: 'Local'),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700)),
                          ]),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: _addBox,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                  l10n.choose(ar: 'إضافة هدف محلي', en: 'Add local goal'))),
        ],
      ),
    );
  }

  void _addBox() {
    final titleC = TextEditingController();
    final targetC = TextEditingController();
    showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
              title: Text(MadadLocalizations.of(context)
                  .choose(ar: 'هدف ادخار محلي', en: 'Local savings goal')),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: titleC,
                    decoration: InputDecoration(
                        labelText: MadadLocalizations.of(context)
                            .choose(ar: 'اسم الهدف', en: 'Goal name'))),
                const SizedBox(height: 12),
                TextField(
                    controller: targetC,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: MadadLocalizations.of(context).choose(
                            ar: 'الهدف (معلومة محلية، ر.ي)',
                            en: 'Target (local note, YER)'))),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text(MadadLocalizations.of(context)
                        .choose(ar: 'إلغاء', en: 'Cancel'))),
                FilledButton(
                    onPressed: () {
                      final t = titleC.text.trim();
                      final tg = double.tryParse(targetC.text);
                      if (t.isNotEmpty) {
                        setState(() => boxes.add({
                              'title': t,
                              'target': tg ?? 0.0,
                              'current': null,
                              'icon': Icons.savings
                            }));
                      }
                      Navigator.pop(c);
                    },
                    child: Text(MadadLocalizations.of(context)
                        .choose(ar: 'حفظ محلي', en: 'Save locally'))),
              ],
            ));
  }
}
