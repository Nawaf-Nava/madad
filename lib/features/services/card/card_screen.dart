import 'package:flutter/material.dart';
import '../../../core/l10n/madad_localizations.dart';
import '../../../core/theme/madad_theme.dart';
import '../../../core/widgets/madad_ui.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});
  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(l10n.choose(ar: 'البطاقة الرقمية', en: 'Digital card'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(ar: 'إدارة البطاقة', en: 'Card management'),
            subtitle: l10n.choose(
                ar: 'الإنشاء والربط يحتاجان إلى مزود معتمد.',
                en: 'Issuance and linking require an authorized provider.'),
            icon: Icons.credit_card_outlined,
          ),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF242B37), Color(0xFF141821)],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF353D4A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.choose(ar: 'بطاقة مَدَد', en: 'MADAD card'),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700)),
                    const Icon(Icons.contactless_rounded,
                        color: MadadColors.orangeLight, size: 28),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                    l10n.choose(
                        ar: 'لا توجد بطاقة متصلة', en: 'No connected card'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                    l10n.choose(
                        ar: 'لا يتم عرض رقم أو بيانات بطاقة وهمية.',
                        en: 'No fictitious card number or details are shown.'),
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MadadNotice(
            icon: Icons.lock_outline_rounded,
            message: l10n.choose(
              ar: 'التفعيل، القفل، إعادة الشحن وكشف البطاقة غير متاحة دون خدمة بطاقات متصلة.',
              en: 'Activation, locking, reload and statements require a connected card service.',
            ),
          ),
        ],
      ),
    );
  }
}
