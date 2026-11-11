import 'package:flutter/material.dart';
import '../../../core/l10n/madad_localizations.dart';
import '../../../core/widgets/madad_ui.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});
  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.choose(ar: 'التبرعات', en: 'Donations'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(ar: 'جهات التبرع', en: 'Donation organizations'),
            subtitle: l10n.choose(
                ar: 'تتطلب القائمة جهة تبرع موثقة.',
                en: 'The list requires a verified organization source.'),
            icon: Icons.volunteer_activism_outlined,
          ),
          MadadNotice(
              message: l10n.choose(
            ar: 'لا توجد جهة أو حملة موثقة متصلة. لم يتم إنشاء تبرع أو خصم مبلغ.',
            en: 'No verified organization or campaign is connected. No donation or charge was created.',
          )),
          SizedBox(
            height: 340,
            child: MadadEmptyState(
              icon: Icons.volunteer_activism_outlined,
              title: l10n.choose(
                  ar: 'لا توجد جهات متاحة', en: 'No organizations available'),
              message: l10n.choose(
                  ar: 'ستظهر الجهات بعد توفر مصدر موثوق.',
                  en: 'Organizations will appear once a trusted source is available.'),
            ),
          ),
        ],
      ),
    );
  }
}
