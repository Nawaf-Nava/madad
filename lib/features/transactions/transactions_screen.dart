import 'package:flutter/material.dart';
import '../../core/l10n/madad_localizations.dart';
import '../../core/theme/madad_theme.dart';
import '../../core/widgets/madad_ui.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final Object? error;
  final Future<void> Function()? onRetry;
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int filter = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    final filters = [
      l10n.choose(ar: 'الكل', en: 'All'),
      l10n.choose(ar: 'تحويلات', en: 'Transfers'),
      l10n.choose(ar: 'مدفوعات', en: 'Payments'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        MadadPageHeader(
          title: l10n.text('transactions'),
          subtitle: l10n.choose(
            ar: 'راجع سجل العمليات والإيصالات',
            en: 'Review activity and receipts',
          ),
          icon: Icons.receipt_long_rounded,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < filters.length; index++)
              ChoiceChip(
                label: Text(filters[index]),
                selected: filter == index,
                onSelected: (_) => setState(() => filter = index),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (widget.error != null)
          MadadNotice(
            icon: Icons.cloud_off_outlined,
            message: l10n.choose(
              ar: 'تعذر تحميل سجل المعاملات من الخادم.',
              en: 'Could not load transactions from the server.',
            ),
          )
        else if (widget.transactions.isEmpty)
          SizedBox(
            height: 300,
            child: MadadEmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.text('noTransactions'),
              message: l10n.choose(
                ar: 'لا توجد معاملات مسجلة لهذا الحساب.',
                en: 'No transactions are recorded for this account.',
              ),
              action: widget.onRetry == null
                  ? null
                  : OutlinedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.choose(ar: 'تحديث', en: 'Refresh')),
                    ),
            ),
          )
        else
          ...widget.transactions
              .where((transaction) => _matchesFilter(transaction))
              .map((transaction) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: MadadColors.orangeSurface,
                        child: Icon(Icons.receipt_long_outlined,
                            color: MadadColors.orange),
                      ),
                      title: Text(
                        '${transaction['type'] ?? ''} · ${transaction['status'] ?? ''}',
                      ),
                      subtitle: Text(
                        (transaction['description'] as String?) ??
                            (transaction['referenceNumber'] as String? ?? ''),
                      ),
                      trailing: Text(
                        '${transaction['amount'] ?? ''} ${transaction['currency'] ?? ''}',
                      ),
                    ),
                  )),
      ],
    );
  }

  bool _matchesFilter(Map<String, dynamic> transaction) {
    if (filter == 0) return true;
    final type = (transaction['type'] as String? ?? '').toLowerCase();
    if (filter == 1) return type.contains('transfer');
    return type.contains('payment') || type.contains('topup');
  }
}
