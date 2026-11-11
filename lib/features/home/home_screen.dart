import 'package:flutter/material.dart';
import '../../core/l10n/madad_localizations.dart';
import '../../core/theme/madad_theme.dart';
import '../../core/widgets/madad_brand_mark.dart';
import '../../core/widgets/madad_ui.dart';
import '../../data/madad_app_scope.dart';
import '../reports/reports_screen.dart';
import '../transfers/transfers_screen.dart';
import '../payments/payments_screen.dart';
import '../payments/qr_scanner_screen.dart';
import '../profile/profile_screen.dart';
import '../services/services_screen.dart';
import '../notifications/notifications_screen.dart';
import '../chat/chat_screen.dart';
import '../services/entertainments/entertainments_screen.dart';
import '../services/hadiah/hadiah_screen.dart';
import '../services/hasalah/hasalah_screen.dart';
import '../services/remittance/remittance_screen.dart';
import '../services/service_unavailable_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  bool balanceVisible = false;
  bool _isLoadingAccountData = true;
  Object? _accountError;
  List<Map<String, dynamic>> _wallets = const [];
  List<Map<String, dynamic>> _transactions = const [];
  bool _didStartLoad = false;
  int _bannerIndex = 0;
  int _walletIndex = 0;
  static const _navTabs = [3, 1, 2, 0];
  late final PageController _walletPageController =
      PageController(viewportFraction: .84);

  @override
  void dispose() {
    _walletPageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _didStartLoad = true;
      _loadAccountData();
    }
  }

  Future<void> _loadAccountData() async {
    final repository = MadadAppScope.of(context).repository;
    setState(() {
      _isLoadingAccountData = true;
      _accountError = null;
    });
    try {
      final results = await Future.wait<List<Map<String, dynamic>>>([
        repository.getWallets(),
        repository.getTransactions(),
      ]);
      if (!mounted) return;
      setState(() {
        _wallets = results[0];
        _transactions = results[1];
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _accountError = error);
    } finally {
      if (mounted) setState(() => _isLoadingAccountData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    final user = MadadAppScope.of(context).auth.session?.user ??
        const <String, dynamic>{};
    final accountName = (user['fullName'] as String?)?.trim();
    final pages = [
      _dashboard(l10n, accountName: accountName),
      ReportsScreen(
        transactions: _transactions,
        isLoading: _isLoadingAccountData,
        error: _accountError,
        onRetry: _loadAccountData,
      ),
      const ServicesScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      appBar: tab == 0 || tab == 2
          ? null
          : AppBar(
              title: Text(l10n.choose(ar: 'أخرى', en: 'More')),
              actions: [
                IconButton(
                  tooltip: l10n.text('notifications'),
                  onPressed: () => Navigator.push(
                      context, madadPageRoute(const NotificationsScreen())),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
      body: SafeArea(
        child: IndexedStack(index: tab, children: pages),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        tooltip: l10n.text('qrScanner'),
        onPressed: () => _push(const QrScannerScreen()),
        child: const Icon(Icons.qr_code_scanner_rounded, size: 30),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navTabs.indexOf(tab),
        onDestinationSelected: (i) => setState(() => tab = _navTabs[i]),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.text('profile')),
          NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.checklist_rounded),
              label: l10n.choose(ar: 'التقارير', en: 'Reports')),
          NavigationDestination(
              icon: const Icon(Icons.work_outline_rounded),
              selectedIcon: const Icon(Icons.work_rounded),
              label: l10n.text('services')),
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.text('home')),
        ],
      ),
    );
  }

  Widget _dashboard(MadadLocalizations l10n, {String? accountName}) =>
      RefreshIndicator(
        onRefresh: _loadAccountData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l10n.choose(ar: 'مرحباً بك', en: 'Welcome'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: MadadColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(accountName?.isNotEmpty == true
                          ? accountName!
                          : l10n.text('appName')),
                      const SizedBox(height: 2),
                      Text(l10n.text('dashboardSubtitle'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: MadadColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _headerAction(
                  icon: Icons.smart_toy_outlined,
                  tooltip:
                      l10n.choose(ar: 'مساعد مَدَد', en: 'MADAD assistant'),
                  onPressed: () => _push(const ChatScreen()),
                ),
                const SizedBox(width: 8),
                _headerAction(
                  icon: Icons.notifications_none_rounded,
                  tooltip: l10n.text('notifications'),
                  onPressed: () => _push(const NotificationsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _accountNotice(l10n),
            const SizedBox(height: 10),
            Center(
              child: Text(
                l10n.choose(
                    ar: 'اسحب للأسفل للتحديث', en: 'Pull down to refresh'),
                style: const TextStyle(
                    color: MadadColors.textSecondary, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            _walletCarousel(l10n),
            const SizedBox(height: 18),
            _walletPageIndicator(),
            const SizedBox(height: 20),
            _promotions(l10n),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(l10n.text('quickServices'),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: MadadColors.textPrimary)),
                ),
                TextButton(
                  onPressed: () => setState(() => tab = 2),
                  child: Text(l10n.text('seeAll')),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _serviceGrid(l10n),
            const SizedBox(height: 26),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.choose(ar: 'العمليات', en: 'Transactions'),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: MadadColors.textPrimary),
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoadingAccountData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_accountError != null)
              MadadNotice(
                icon: Icons.cloud_off_outlined,
                message: l10n.choose(
                  ar: 'تعذر تحميل بيانات الحساب. تحقق من اتصال خادم مَدَد.',
                  en: 'Account data could not be loaded. Check the MADAD server connection.',
                ),
              )
            else if (_transactions.isEmpty)
              _emptyTransactions(l10n)
            else
              ..._transactions.take(3).map((transaction) => _transaction(
                    '${transaction['type'] ?? l10n.text('transactions')} · ${transaction['status'] ?? ''}',
                    (transaction['description'] as String?) ??
                        (transaction['referenceNumber'] as String? ?? ''),
                    Icons.receipt_long_outlined,
                    '${transaction['amount'] ?? ''} ${transaction['currency'] ?? ''}',
                  )),
          ],
        ),
      );

  Widget _headerAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) =>
      Material(
        color: MadadColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: MadadColors.textSecondary, size: 25),
        ),
      );

  Widget _accountNotice(MadadLocalizations l10n) => InkWell(
        onTap: () => setState(() => tab = 3),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: MadadColors.orange.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: MadadColors.orange.withValues(alpha: .16)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_rounded, color: MadadColors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.choose(
                    ar: 'بعض الخدمات المالية غير متصلة في هذه النسخة',
                    en: 'Some financial services are not connected in this build',
                  ),
                  style: const TextStyle(
                    color: MadadColors.orangeLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: MadadColors.orange),
            ],
          ),
        ),
      );

  Widget _walletCarousel(MadadLocalizations l10n) {
    final count = _wallets.isEmpty ? 1 : _wallets.length;
    return SizedBox(
      height: 190,
      child: PageView.builder(
        controller: _walletPageController,
        itemCount: count,
        onPageChanged: (index) => setState(() => _walletIndex = index),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _walletCard(l10n, _wallets.isEmpty ? null : _wallets[index]),
        ),
      ),
    );
  }

  Widget _walletCard(MadadLocalizations l10n, Map<String, dynamic>? wallet) {
    final currency = wallet?['currency'] as String? ?? 'YER';
    final balance = wallet?['balance'];
    final accountLabel = wallet?['name'] as String? ??
        l10n.choose(ar: 'حساب مَدَد', en: 'MADAD account');
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MadadColors.orange, MadadColors.orangeDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            start: -55,
            bottom: -105,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: .12), width: 22),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: MadadBrandMark(size: 48),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l10n.text('walletBalance'),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(accountLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      balanceVisible
                          ? (balance == null
                              ? l10n.text('balanceUnavailable')
                              : '$balance $currency')
                          : '••••••',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: balanceVisible
                        ? l10n.choose(ar: 'إخفاء الرصيد', en: 'Hide balance')
                        : l10n.choose(ar: 'إظهار الرصيد', en: 'Show balance'),
                    onPressed: () =>
                        setState(() => balanceVisible = !balanceVisible),
                    icon: Icon(
                      balanceVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletPageIndicator() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0;
              index < (_wallets.isEmpty ? 1 : _wallets.length);
              index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: index == _walletIndex ? 10 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: index == _walletIndex
                    ? MadadColors.orange
                    : MadadColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      );

  Widget _promotions(MadadLocalizations l10n) {
    final cards = <({
      String ar,
      String en,
      String subAr,
      String subEn,
      IconData icon,
      Widget Function() page
    })>[
      (
        ar: 'ابدأ الادخار مع مَدَد',
        en: 'Start saving with MADAD',
        subAr: 'أهداف ادخار محلية',
        subEn: 'Local savings goals',
        icon: Icons.savings_rounded,
        page: () => const HasalahScreen(),
      ),
      (
        ar: 'خدماتك المالية في مكان واحد',
        en: 'Your services in one place',
        subAr: 'تصفح خدمات مَدَد',
        subEn: 'Browse MADAD services',
        icon: Icons.account_balance_wallet_rounded,
        page: () => const ServicesScreen(),
      ),
      (
        ar: 'شارك فرحتك بهدية',
        en: 'Share a gift',
        subAr: 'معاينة دون إرسال أموال',
        subEn: 'Preview only; no money is sent',
        icon: Icons.card_giftcard_rounded,
        page: () => const HadiahScreen(),
      ),
    ];
    return Column(
      children: [
        SizedBox(
          height: 104,
          child: PageView.builder(
            itemCount: cards.length,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              final card = cards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Material(
                  color: MadadColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _push(card.page()),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            MadadColors.orange.withValues(alpha: .38),
                            MadadColors.surface,
                            MadadColors.background,
                          ],
                          begin: AlignmentDirectional.centerStart,
                          end: AlignmentDirectional.centerEnd,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Icon(card.icon,
                                color: MadadColors.orangeLight, size: 48),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    l10n.choose(ar: card.ar, en: card.en),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: MadadColors.orangeLight,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.choose(ar: card.subAr, en: card.subEn),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: MadadColors.textPrimary,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < cards.length; index++)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index == _bannerIndex
                      ? MadadColors.orange
                      : MadadColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _serviceGrid(MadadLocalizations l10n) {
    final services =
        <({String ar, String en, IconData icon, Widget Function() page})>[
      (
        ar: 'تحويلات مالية',
        en: 'Money transfers',
        icon: Icons.swap_horiz_rounded,
        page: () => const TransfersScreen(),
      ),
      (
        ar: 'حوالات محلية',
        en: 'Local remittance',
        icon: Icons.send_rounded,
        page: () => const RemittanceScreen(),
      ),
      (
        ar: 'الشحن والسداد',
        en: 'Top-up and bills',
        icon: Icons.receipt_long_rounded,
        page: () => const PaymentsScreen(initial: 'شحن رصيد'),
      ),
      (
        ar: 'سحب نقدي',
        en: 'Cash withdrawal',
        icon: Icons.local_atm_rounded,
        page: () => ServiceUnavailableScreen(
            title: l10n.choose(ar: 'سحب نقدي', en: 'Cash withdrawal')),
      ),
      (
        ar: 'دفع المشتريات',
        en: 'Purchase payments',
        icon: Icons.shopping_bag_outlined,
        page: () => const PaymentsScreen(initial: 'فواتير وخدمات'),
      ),
      (
        ar: 'شراء أونلاين',
        en: 'Online purchases',
        icon: Icons.contactless_rounded,
        page: () => ServiceUnavailableScreen(
            title: l10n.choose(ar: 'شراء أونلاين', en: 'Online purchases')),
      ),
      (
        ar: 'جيبي',
        en: 'Gifts',
        icon: Icons.card_giftcard_rounded,
        page: () => const HadiahScreen(),
      ),
      (
        ar: 'خدمات ترفيه',
        en: 'Entertainment',
        icon: Icons.sports_esports_outlined,
        page: () => const EntertainmentsScreen(),
      ),
      (
        ar: 'المدفوعات',
        en: 'Payments',
        icon: Icons.account_balance_wallet_outlined,
        page: () => const PaymentsScreen(),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .9,
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return _serviceCard(
          l10n.choose(ar: service.ar, en: service.en),
          service.icon,
          () => _push(service.page()),
          isNew: index == 6,
        );
      },
    );
  }

  Widget _serviceCard(String title, IconData icon, VoidCallback onTap,
          {bool isNew = false}) =>
      Material(
        color: MadadColors.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: MadadColors.orange, size: 35),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MadadColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isNew)
                PositionedDirectional(
                  top: 8,
                  start: 8,
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

  Widget _emptyTransactions(MadadLocalizations l10n) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 66, color: MadadColors.textSecondary),
            const SizedBox(height: 14),
            Text(
              l10n.text('noTransactions'),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: MadadColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.choose(
                ar: 'قم بالتحويل أو دفع مشترياتك عن طريق محفظة مَدَد لمشاهدة عملياتك.',
                en: 'Make a transfer or pay with your MADAD wallet to see activity here.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: MadadColors.textSecondary, fontSize: 15, height: 1.5),
            ),
          ],
        ),
      );

  Widget _transaction(
          String title, String subtitle, IconData icon, String amount) =>
      Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
              backgroundColor: MadadColors.surface,
              child: Icon(icon, color: MadadColors.textSecondary)),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: MadadColors.textPrimary)),
          subtitle: Text(subtitle,
              style: const TextStyle(
                  color: MadadColors.textSecondary, fontSize: 12)),
          trailing: Text(amount,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: MadadColors.textPrimary)),
        ),
      );

  void _push(Widget page) => Navigator.of(context).push(madadPageRoute(page));
}
