import 'package:flutter/material.dart';
import '../../../core/l10n/madad_localizations.dart';
import '../../../core/widgets/madad_ui.dart';

class EntertainmentsScreen extends StatelessWidget {
  const EntertainmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          title:
              Text(l10n.choose(ar: 'القسائم الرقمية', en: 'Digital vouchers'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(
                ar: 'الترفيه والقسائم', en: 'Entertainment and vouchers'),
            subtitle: l10n.choose(
                ar: 'تتطلب المنتجات اتصالاً بمزود معتمد.',
                en: 'Products require a connected authorized provider.'),
            icon: Icons.sports_esports_outlined,
          ),
          MadadNotice(
              message: l10n.choose(
            ar: 'لا توجد منتجات أو أسعار موثقة متصلة. لم يتم إنشاء عملية شراء.',
            en: 'No verified products or prices are connected. No purchase was created.',
          )),
          SizedBox(
            height: 330,
            child: MadadEmptyState(
              icon: Icons.local_activity_outlined,
              title: l10n.choose(
                  ar: 'القسائم غير متاحة', en: 'Vouchers unavailable'),
              message: l10n.choose(
                  ar: 'ستظهر المنتجات بعد ربط مزود خدمة.',
                  en: 'Products will appear after a provider is connected.'),
            ),
          ),
        ],
      ),
    );
  }
}
