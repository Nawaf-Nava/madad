import 'package:flutter/material.dart';

import '../../../core/l10n/madad_localizations.dart';
import '../../../core/theme/madad_theme.dart';
import '../../../core/widgets/madad_ui.dart';

class SubWalletsScreen extends StatefulWidget {
  const SubWalletsScreen({super.key});
  @override
  State<SubWalletsScreen> createState() => _SubWalletsScreenState();
}

class _SubWalletsScreenState extends State<SubWalletsScreen> {
  final wallets = <Map<String, dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(l10n.choose(ar: 'محافظ العائلة', en: 'Family wallets'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(ar: 'المحافظ الفرعية', en: 'Sub-wallets'),
            subtitle: l10n.choose(
                ar: 'أسماء المحفظة محلية؛ الرصيد غير متصل.',
                en: 'Wallet labels are local; balances are not connected.'),
            icon: Icons.account_balance_wallet_outlined,
          ),
          MadadNotice(
              message: l10n.choose(
            ar: 'لا توجد محفظة عائلة متصلة. لن يتم تنفيذ تغذية أو سحب في هذه المعاينة.',
            en: 'No family wallet is connected. Cash-in and cash-out are unavailable in this preview.',
          )),
          if (wallets.isEmpty)
            SizedBox(
              height: 270,
              child: MadadEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.choose(
                    ar: 'لا توجد محافظ عائلة', en: 'No family wallets'),
                message: l10n.choose(
                    ar: 'يمكنك إضافة اسم محلي للمعاينة دون إنشاء حساب مالي.',
                    en: 'Add a local preview label without creating a financial account.'),
              ),
            ),
          ...wallets.map((w) => Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const CircleAvatar(
                                  backgroundColor: MadadColors.orangePale,
                                  child: Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: MadadColors.orange)),
                              const SizedBox(width: 12),
                              Text(w['name'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                            ]),
                            Chip(
                                label:
                                    Text(l10n.choose(ar: 'محلي', en: 'Local'))),
                          ]),
                      const SizedBox(height: 14),
                      Text(
                          l10n.choose(
                              ar: 'الرصيد غير متاح', en: 'Balance unavailable'),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: MadadColors.textSecondary)),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(
                            child: OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(l10n.choose(
                                    ar: 'تغذية غير متاحة',
                                    en: 'Cash-in unavailable')))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.remove, size: 16),
                                label: Text(l10n.choose(
                                    ar: 'سحب غير متاح',
                                    en: 'Cash-out unavailable')))),
                      ]),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: _createWallet,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(l10n.choose(
                  ar: 'إضافة اسم محفظة محلي', en: 'Add local wallet label'))),
        ],
      ),
    );
  }

  void _createWallet() {
    final nameC = TextEditingController();
    showDialog<void>(
        context: context,
        builder: (d) => AlertDialog(
              title: Text(MadadLocalizations.of(context)
                  .choose(ar: 'اسم محفظة محلي', en: 'Local wallet label')),
              content: TextField(
                  controller: nameC,
                  decoration: InputDecoration(
                      labelText: MadadLocalizations.of(context)
                          .choose(ar: 'اسم المحفظة', en: 'Wallet name'))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(d),
                    child: Text(MadadLocalizations.of(context)
                        .choose(ar: 'إلغاء', en: 'Cancel'))),
                FilledButton(
                    onPressed: () {
                      final n = nameC.text.trim();
                      if (n.isNotEmpty) {
                        setState(() => wallets.add(
                            {'name': n, 'balance': null, 'status': 'local'}));
                      }
                      Navigator.pop(d);
                    },
                    child: Text(MadadLocalizations.of(context)
                        .choose(ar: 'حفظ محلي', en: 'Save locally')))
              ],
            ));
  }
}
