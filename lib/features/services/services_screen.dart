import 'package:flutter/material.dart';

import '../../core/l10n/madad_localizations.dart';
import '../../core/theme/madad_theme.dart';
import '../../core/widgets/madad_ui.dart';
import '../account/account_tools_screen.dart';
import '../chat/chat_screen.dart';
import '../notifications/notifications_screen.dart';
import '../payments/payments_screen.dart';
import '../transfers/transfers_screen.dart';
import 'branches/branches_screen.dart';
import 'card/card_screen.dart';
import 'donations/donations_screen.dart';
import 'entertainments/entertainments_screen.dart';
import 'hadiah/hadiah_screen.dart';
import 'hasalah/hasalah_screen.dart';
import 'remittance/remittance_screen.dart';
import 'service_unavailable_screen.dart';
import 'subwallets/subwallets_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, this.initial});

  final String? initial;

  static const entries = <_ServiceEntry>[
    _ServiceEntry('cash_withdrawal', 'طلب سحب نقدي', 'Cash withdrawal request',
        Icons.local_atm_rounded),
    _ServiceEntry('shared_transfer', 'تحويل إلى مشترك', 'Transfer to member',
        Icons.call_made_rounded),
    _ServiceEntry('purchase_payment', 'دفع المشتريات', 'Purchase payment',
        Icons.shopping_bag_outlined),
    _ServiceEntry('network_send', 'إرسال حوالة شبكة تحويل',
        'Send network remittance', Icons.outbound_rounded),
    _ServiceEntry('banks_wallets', 'بنوك ومحافظ', 'Banks and wallets',
        Icons.account_balance_outlined),
    _ServiceEntry('local_receive_network', 'استلام حوالة عبر شبكات محلية',
        'Receive local network remittance', Icons.move_to_inbox_outlined),
    _ServiceEntry('remittance_status', 'حالة حوالة', 'Remittance status',
        Icons.pending_actions_rounded),
    _ServiceEntry('network_receive', 'إرسال حوالة عبر شبكات محلية',
        'Local network transfer', Icons.send_to_mobile_rounded),
    _ServiceEntry('cancel_remittance', 'إلغاء حوالة', 'Cancel remittance',
        Icons.cancel_outlined),
    _ServiceEntry('topup', 'الشحن والسداد', 'Top-up and bills',
        Icons.bookmark_border_rounded),
    _ServiceEntry('own_transfer', 'تحويل بين حساباتي (مصارف)',
        'Between my bank accounts', Icons.account_balance_wallet_outlined),
    _ServiceEntry('local_receive', 'طلب استلام حوالة محلية',
        'Request local remittance', Icons.south_west_rounded),
    _ServiceEntry('other_wallets', 'تحويل إلى محافظ أخرى',
        'Transfer to other wallets', Icons.wallet_outlined),
    _ServiceEntry('international_receive', 'طلب استلام حوالة دولية',
        'Request international remittance', Icons.public_rounded),
    _ServiceEntry('atm_ykb', 'سحب من الصراف الآلي YKB', 'YKB ATM withdrawal',
        Icons.atm_rounded),
    _ServiceEntry(
        'purchase_code', 'كود شراء', 'Purchase code', Icons.password_rounded),
    _ServiceEntry('atm_cac', 'سحب من الصراف الآلي كاك بنك',
        'CAC Bank ATM withdrawal', Icons.account_balance_rounded),
    _ServiceEntry('internet_cards', 'بطاقات نت', 'Internet cards',
        Icons.sim_card_outlined),
    _ServiceEntry('games', 'ألعاب', 'Games', Icons.sports_esports_outlined),
    _ServiceEntry('apps', 'تطبيقات', 'Apps', Icons.favorite_border_rounded),
    _ServiceEntry('national_payment', 'تسديد الوطنية للتحويل الأصغر',
        'National microfinance payment', Icons.assured_workload_outlined),
    _ServiceEntry(
        'donations', 'تبرعات', 'Donations', Icons.volunteer_activism_outlined),
    _ServiceEntry('virtual_cards', 'البطاقات الافتراضية', 'Virtual cards',
        Icons.credit_card_outlined),
    _ServiceEntry(
        'family', 'جيب العائلة', 'Family wallet', Icons.people_alt_outlined,
        isNew: true),
    _ServiceEntry(
        'farqak', 'فِرقك', 'Your groups', Icons.pie_chart_outline_rounded,
        isNew: true),
    _ServiceEntry('gifts', 'هدية', 'Gift', Icons.card_giftcard_rounded,
        isNew: true),
    _ServiceEntry('savings', 'حصالة', 'Savings box', Icons.savings_outlined),
  ];

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<String?> _shortcuts = [null, null, null];

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: l10n.text('notifications'),
                onPressed: () => Navigator.push(
                  context,
                  madadPageRoute(const NotificationsScreen()),
                ),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.choose(ar: 'مرحباً بك', en: 'Welcome'),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: MadadColors.textPrimary)),
                  Text(l10n.text('services'),
                      style: const TextStyle(
                          fontSize: 16, color: MadadColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _sectionTitle(
                  l10n.choose(ar: 'تخصيص خدمات', en: 'Customize services')),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var index = 0; index < _shortcuts.length; index++) ...[
                    if (index != 0) const SizedBox(width: 10),
                    Expanded(child: _shortcutTile(index, l10n)),
                  ],
                ],
              ),
              const SizedBox(height: 22),
              _sectionTitle(
                  l10n.choose(ar: 'كافة الخدمات', en: 'All services')),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ServicesScreen.entries.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: .9,
                ),
                itemBuilder: (context, index) =>
                    _serviceTile(ServicesScreen.entries[index]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 4),
          child: Text(title,
              style: const TextStyle(
                  color: MadadColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
        ),
      );

  Widget _shortcutTile(int index, MadadLocalizations l10n) {
    final id = _shortcuts[index];
    final entry = id == null
        ? null
        : ServicesScreen.entries.firstWhere((item) => item.id == id);
    return Material(
      color: MadadColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => entry == null ? _chooseShortcut(index) : _open(entry),
        child: SizedBox(
          height: 82,
          child: Center(
            child: entry == null
                ? const Icon(Icons.add_rounded,
                    color: MadadColors.orange, size: 38)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(entry.icon, color: MadadColors.orange, size: 27),
                      const SizedBox(height: 4),
                      Text(
                        l10n.choose(ar: entry.titleAr, en: entry.titleEn),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: MadadColors.textPrimary, fontSize: 11),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _chooseShortcut(int index) async {
    final l10n = MadadLocalizations.of(context);
    final selected = await showModalBottomSheet<_ServiceEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MadadColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .72,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  l10n.choose(
                      ar: 'اختر خدمة للاختصارات', en: 'Choose a shortcut'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ServicesScreen.entries.length,
                  itemBuilder: (context, itemIndex) {
                    final entry = ServicesScreen.entries[itemIndex];
                    return ListTile(
                      leading: Icon(entry.icon, color: MadadColors.orange),
                      title: Text(
                          l10n.choose(ar: entry.titleAr, en: entry.titleEn)),
                      onTap: () => Navigator.pop(context, entry),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _shortcuts[index] = selected.id);
    }
  }

  Widget _serviceTile(_ServiceEntry entry) => Material(
        color: MadadColors.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _open(entry),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(entry.icon, color: MadadColors.orange, size: 34),
                      const SizedBox(height: 9),
                      Text(
                        MadadLocalizations.of(context)
                            .choose(ar: entry.titleAr, en: entry.titleEn),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MadadColors.textPrimary,
                          fontSize: 13,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (entry.isNew)
                PositionedDirectional(
                  top: 8,
                  start: 7,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: MadadColors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      MadadLocalizations.of(context)
                          .choose(ar: 'جديد', en: 'New'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  void _open(_ServiceEntry entry) {
    final l10n = MadadLocalizations.of(context);
    final title = l10n.choose(ar: entry.titleAr, en: entry.titleEn);
    final Widget page = switch (entry.id) {
      'shared_transfer' ||
      'banks_wallets' ||
      'other_wallets' ||
      'own_transfer' =>
        const TransfersScreen(),
      'purchase_payment' || 'topup' => const PaymentsScreen(),
      'network_send' ||
      'local_receive_network' ||
      'remittance_status' ||
      'network_receive' ||
      'cancel_remittance' ||
      'local_receive' ||
      'international_receive' =>
        const RemittanceScreen(),
      'donations' => const DonationsScreen(),
      'internet_cards' ||
      'games' ||
      'apps' ||
      'purchase_code' =>
        const EntertainmentsScreen(),
      'virtual_cards' => const CardScreen(),
      'family' => const SubWalletsScreen(),
      'gifts' => const HadiahScreen(),
      'savings' => const HasalahScreen(),
      'branches' => const BranchesScreen(),
      'beneficiaries' => const AccountToolsScreen(),
      'support' => const ChatScreen(),
      _ => ServiceUnavailableScreen(title: title),
    };
    Navigator.push(context, madadPageRoute(page));
  }
}

class _ServiceEntry {
  const _ServiceEntry(
    this.id,
    this.titleAr,
    this.titleEn,
    this.icon, {
    this.isNew = false,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final bool isNew;
}
