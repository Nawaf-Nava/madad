import 'package:flutter/material.dart';
import '../../core/l10n/madad_localizations.dart';
import '../../core/widgets/madad_ui.dart';

class AccountToolsScreen extends StatefulWidget {
  const AccountToolsScreen({super.key});
  @override
  State<AccountToolsScreen> createState() => _AccountToolsScreenState();
}

class _AccountToolsScreenState extends State<AccountToolsScreen> {
  final names = <String>[];
  bool biometric = false;
  bool maskName = false;

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.choose(ar: 'أدوات الحساب', en: 'Account tools')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(ar: 'المستفيدون', en: 'Beneficiaries'),
            subtitle: l10n.choose(
              ar: 'تُحفظ الأسماء المضافة محلياً على هذا الجهاز.',
              en: 'Names added here are stored locally on this device.',
            ),
            icon: Icons.people_outline_rounded,
          ),
          if (names.isEmpty)
            SizedBox(
              height: 190,
              child: MadadEmptyState(
                icon: Icons.person_search_outlined,
                title:
                    l10n.choose(ar: 'لا يوجد مستفيدون', en: 'No beneficiaries'),
                message: l10n.choose(
                  ar: 'أضف اسماً لحفظه في هذه الواجهة المحلية.',
                  en: 'Add a name to save it in this local-only list.',
                ),
              ),
            )
          else
            ...names.map(
              (name) => Card(
                child: ListTile(
                  title: Text(name),
                  leading: const Icon(Icons.person_outline),
                  trailing: IconButton(
                    tooltip: l10n.choose(ar: 'حذف', en: 'Remove'),
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => names.remove(name)),
                  ),
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: _addBeneficiary,
            icon: const Icon(Icons.person_add_alt_1),
            label:
                Text(l10n.choose(ar: 'إضافة اسم محلي', en: 'Add local name')),
          ),
          const SizedBox(height: 20),
          MadadSectionTitle(l10n.text('securityPrivacy')),
          SwitchListTile(
            value: biometric,
            onChanged: (value) => setState(() => biometric = value),
            title: Text(l10n.choose(
                ar: 'تفضيل واجهة البصمة', en: 'Biometric UI preference')),
            subtitle: Text(l10n.choose(
              ar: 'تفضيل محلي فقط؛ لا يحمي معاملات فعلية.',
              en: 'Local preference only; it does not secure transactions.',
            )),
          ),
          SwitchListTile(
            value: maskName,
            onChanged: (value) => setState(() => maskName = value),
            title: Text(l10n.choose(
                ar: 'إخفاء الاسم في العرض', en: 'Mask name in display')),
            subtitle: Text(l10n.choose(
                ar: 'تفضيل محلي للواجهة فقط.',
                en: 'Local display preference only.')),
          ),
          const SizedBox(height: 12),
          MadadNotice(
            icon: Icons.shield_outlined,
            message: l10n.choose(
              ar: 'الإعدادات هنا محلية للواجهة. لا تحفظ هذه النسخة كلمات مرور أو رموز تحقق، ولا تتصل بخدمات Jaib.',
              en: 'These are local UI preferences. This build stores no passwords or verification codes and does not connect to Jaib services.',
            ),
          ),
        ],
      ),
    );
  }

  void _addBeneficiary() {
    final c = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(MadadLocalizations.of(context).choose(
          ar: 'مستفيد محلي',
          en: 'Local beneficiary',
        )),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(
            labelText:
                MadadLocalizations.of(context).choose(ar: 'الاسم', en: 'Name'),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d),
              child: Text(MadadLocalizations.of(context)
                  .choose(ar: 'إلغاء', en: 'Cancel'))),
          FilledButton(
            onPressed: () {
              final name = c.text.trim();
              if (name.isEmpty ||
                  names.any((n) => n.toLowerCase() == name.toLowerCase())) {
                return;
              }
              setState(() => names.add(name));
              Navigator.pop(d);
            },
            child: Text(MadadLocalizations.of(context)
                .choose(ar: 'حفظ محلي', en: 'Save locally')),
          ),
        ],
      ),
    );
  }
}
