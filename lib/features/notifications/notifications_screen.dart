import 'package:flutter/material.dart';
import '../../../core/l10n/madad_localizations.dart';
import '../../../core/theme/madad_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.text('notifications')),
        centerTitle: true,
        leadingWidth: 150,
        leading: Row(
          children: [
            IconButton(
              tooltip: l10n.choose(ar: 'رجوع', en: 'Back'),
              onPressed: () => Navigator.maybePop(context),
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_right_rounded
                    : Icons.chevron_left_rounded,
                size: 32,
              ),
            ),
            IconButton(
              tooltip: l10n.choose(ar: 'بحث', en: 'Search'),
              onPressed: () => showSearch<void>(
                context: context,
                delegate: _NotificationSearchDelegate(l10n),
              ),
              icon: const Icon(Icons.search_rounded, size: 29),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.choose(
                  ar: 'لا يوجد مصدر إشعارات متصل للتحديث.',
                  en: 'No notification source is connected to refresh.',
                )),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(l10n.choose(ar: 'تحديث', en: 'Refresh')),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 82,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        size: 78, color: MadadColors.textSecondary),
                    Positioned(
                      bottom: 3,
                      child: Container(
                        width: 24,
                        height: 9,
                        decoration: BoxDecoration(
                          color: MadadColors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                l10n.choose(ar: 'لا يوجد إشعارات', en: 'No notifications'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: MadadColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.choose(
                  ar: 'قم بالتحويل أو دفع مشترياتك عن طريق محفظة مَدَد لمشاهدة إشعاراتك',
                  en: 'Make a transfer or pay with your MADAD wallet to see your notifications.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: MadadColors.textSecondary,
                  fontSize: 17,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationSearchDelegate extends SearchDelegate<void> {
  _NotificationSearchDelegate(this.l10n);

  final MadadLocalizations l10n;

  @override
  String get searchFieldLabel => l10n.choose(ar: 'بحث', en: 'Search');

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          tooltip: l10n.choose(ar: 'مسح', en: 'Clear'),
          onPressed: () => query = '',
          icon: const Icon(Icons.clear_rounded),
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        tooltip: l10n.choose(ar: 'رجوع', en: 'Back'),
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_rounded),
      );

  @override
  Widget buildResults(BuildContext context) => _emptyResult();

  @override
  Widget buildSuggestions(BuildContext context) => _emptyResult();

  Widget _emptyResult() => Center(
        child: Text(
          l10n.choose(
              ar: 'لا توجد إشعارات للبحث عنها',
              en: 'There are no notifications to search'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: MadadColors.textSecondary),
        ),
      );
}
