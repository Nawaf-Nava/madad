import 'package:flutter/material.dart';

import '../../core/l10n/madad_localizations.dart';
import '../../core/theme/madad_theme.dart';
import '../../core/widgets/madad_ui.dart';
import '../transactions/transactions_screen.dart';

enum _ReportKind { latest, statement, custom, reference }

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({
    required this.transactions,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    super.key,
  });

  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    final items = <({String ar, String en, IconData icon, _ReportKind kind})>[
      (
        ar: 'آخر العمليات',
        en: 'Recent transactions',
        icon: Icons.checklist_rounded,
        kind: _ReportKind.latest,
      ),
      (
        ar: 'كشف حساب',
        en: 'Account statement',
        icon: Icons.receipt_long_outlined,
        kind: _ReportKind.statement,
      ),
      (
        ar: 'بحث مخصص',
        en: 'Custom search',
        icon: Icons.filter_alt_outlined,
        kind: _ReportKind.custom,
      ),
      (
        ar: 'بحث بالرقم المرجعي',
        en: 'Search by reference',
        icon: Icons.filter_alt_outlined,
        kind: _ReportKind.reference,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        for (final item in items) ...[
          _ReportMenuTile(
            title: l10n.choose(ar: item.ar, en: item.en),
            icon: item.icon,
            onTap: () => _openReport(context, item.kind),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  void _openReport(BuildContext context, _ReportKind kind) {
    final l10n = MadadLocalizations.of(context);
    final title = switch (kind) {
      _ReportKind.latest =>
        l10n.choose(ar: 'آخر العمليات', en: 'Recent transactions'),
      _ReportKind.statement =>
        l10n.choose(ar: 'كشف حساب', en: 'Account statement'),
      _ReportKind.custom => l10n.choose(ar: 'بحث مخصص', en: 'Custom search'),
      _ReportKind.reference =>
        l10n.choose(ar: 'بحث بالرقم المرجعي', en: 'Search by reference'),
    };
    if (kind == _ReportKind.reference) {
      _showReferenceSearch(context);
      return;
    }
    Navigator.push<void>(
      context,
      madadPageRoute<void>(
        _ReportResultScreen(
          kind: kind,
          title: title,
          transactions: transactions,
          isLoading: isLoading,
          error: error,
          onRetry: onRetry,
        ),
      ),
    );
  }

  Future<void> _showReferenceSearch(BuildContext context) async {
    final l10n = MadadLocalizations.of(context);
    final reference = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MadadColors.card,
      builder: (_) => _ReferenceSearchSheet(l10n: l10n),
    );
    if (reference == null || !context.mounted) return;
    Navigator.push<void>(
      context,
      madadPageRoute<void>(
        _ReportResultScreen(
          kind: _ReportKind.reference,
          title: l10n.choose(ar: 'بحث مخصص', en: 'Custom search'),
          queryDescription: l10n.choose(
            ar: 'الرقم المرجعي: $reference',
            en: 'Reference: $reference',
          ),
        ),
      ),
    );
  }
}

class _ReferenceSearchSheet extends StatefulWidget {
  const _ReferenceSearchSheet({required this.l10n});

  final MadadLocalizations l10n;

  @override
  State<_ReferenceSearchSheet> createState() => _ReferenceSearchSheetState();
}

class _ReferenceSearchSheetState extends State<_ReferenceSearchSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          20,
          22,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetCloseButton(onPressed: () => Navigator.pop(context)),
                const SizedBox(height: 18),
                Text(
                  l10n.choose(
                      ar: 'رقم مرجع العملية', en: 'Transaction reference'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: l10n.choose(
                        ar: 'رقم مرجع العملية', en: 'Transaction reference'),
                  ),
                  validator: (value) {
                    final input = value?.trim() ?? '';
                    if (!RegExp(r'^\d+$').hasMatch(input)) {
                      return l10n.choose(
                          ar: 'أدخل أرقاماً فقط', en: 'Enter digits only');
                    }
                    if (input.length < 10 || input.length > 16) {
                      return l10n.choose(
                        ar: 'يجب أن يكون الرقم المرجعي بين 10 و16 رقماً',
                        en: 'Reference must contain 10 to 16 digits',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    l10n.choose(
                      ar: 'يجب أن يكون الرقم المرجعي بين 10 و16 رقماً',
                      en: 'The reference must be 10 to 16 digits.',
                    ),
                    style: const TextStyle(
                        color: MadadColors.textSecondary, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pop(context, _controller.text.trim());
                      }
                    },
                    child: Text(l10n.choose(ar: 'بحث', en: 'Search')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportMenuTile extends StatelessWidget {
  const _ReportMenuTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: MadadColors.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 112,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: MadadColors.background,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: MadadColors.orange, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: MadadColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _ReportResultScreen extends StatefulWidget {
  const _ReportResultScreen({
    required this.kind,
    required this.title,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.queryDescription,
  });

  final _ReportKind kind;
  final String title;
  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final Object? error;
  final Future<void> Function()? onRetry;
  final String? queryDescription;

  @override
  State<_ReportResultScreen> createState() => _ReportResultScreenState();
}

class _ReportResultScreenState extends State<_ReportResultScreen> {
  String _filterDescription = '';

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    final isLatest = widget.kind == _ReportKind.latest;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!isLatest && widget.kind != _ReportKind.reference)
            _ReportAction(
              icon: Icons.filter_alt_outlined,
              label: l10n.choose(ar: 'فلتر', en: 'Filter'),
              onPressed: _openFilters,
            ),
          if (isLatest)
            _ReportAction(
              icon: Icons.file_upload_outlined,
              label: l10n.choose(ar: 'تصدير', en: 'Export'),
              onPressed: _unavailableExport,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (widget.kind == _ReportKind.statement)
            _filterChips(l10n, statement: true),
          if (widget.kind == _ReportKind.custom &&
              _filterDescription.isNotEmpty)
            _filterChips(l10n, statement: false),
          if (widget.queryDescription != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(widget.queryDescription!,
                    style: const TextStyle(color: MadadColors.orange)),
              ),
            ),
          Expanded(child: _reportBody(l10n)),
        ],
      ),
    );
  }

  Widget _filterChips(MadadLocalizations l10n, {required bool statement}) =>
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(
          children: [
            _summaryChip(
                l10n.choose(ar: 'كافة العمليات', en: 'All transactions')),
            const SizedBox(width: 8),
            _summaryChip(l10n.choose(ar: 'كافة الخدمات', en: 'All services')),
            if (_filterDescription.isNotEmpty) ...[
              const SizedBox(width: 8),
              _summaryChip(_filterDescription),
            ] else if (statement) ...[
              const SizedBox(width: 8),
              _summaryChip(l10n.choose(ar: 'كل الفترات', en: 'All dates')),
            ],
          ],
        ),
      );

  Widget _summaryChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: MadadColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: const TextStyle(
                color: MadadColors.orange, fontWeight: FontWeight.w700)),
      );

  Widget _reportBody(MadadLocalizations l10n) {
    if (widget.kind == _ReportKind.latest && widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.kind == _ReportKind.latest && widget.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: MadadNotice(
            icon: Icons.cloud_off_outlined,
            message: l10n.choose(
              ar: 'تعذر تحميل سجل العمليات من الخادم.',
              en: 'Could not load transactions from the server.',
            ),
          ),
        ),
      );
    }
    if (widget.kind == _ReportKind.latest && widget.transactions.isNotEmpty) {
      return TransactionsScreen(
        transactions: widget.transactions,
        isLoading: widget.isLoading,
        error: widget.error,
        onRetry: widget.onRetry,
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined,
                color: MadadColors.textSecondary, size: 76),
            const SizedBox(height: 24),
            Text(
              l10n.choose(ar: 'لا يوجد عمليات', en: 'No transactions'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MadadColors.textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.kind == _ReportKind.latest
                  ? l10n.choose(
                      ar: 'قم بالتحويل أو دفع مشترياتك عن طريق محفظة مَدَد لمشاهدة عملياتك',
                      en: 'Make a transfer or pay with your MADAD wallet to see activity here.',
                    )
                  : widget.kind == _ReportKind.custom
                      ? l10n.choose(
                          ar: 'لا يوجد عمليات للفلتر الذي قمت باختياره، قم بتغيير الفترة لعرض نتائج أفضل',
                          en: 'No transactions match these filters. Change the date range to see other results.',
                        )
                      : l10n.choose(
                          ar: 'لا توجد بيانات مطابقة للبحث حالياً.',
                          en: 'No matching report data is available.',
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
    );
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MadadColors.card,
      builder: (context) => _ReportFilterSheet(
        custom: widget.kind == _ReportKind.custom,
      ),
    );
    if (result != null && mounted) setState(() => _filterDescription = result);
  }

  void _unavailableExport() {
    final l10n = MadadLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.choose(
          ar: 'التصدير غير متاح لعدم توفر بيانات عمليات.',
          en: 'Export is unavailable because no transaction data is available.',
        )),
      ),
    );
  }
}

class _ReportAction extends StatelessWidget {
  const _ReportAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 5),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: TextButton.styleFrom(
            backgroundColor: MadadColors.card,
            foregroundColor: MadadColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      );
}

class _ReportFilterSheet extends StatefulWidget {
  const _ReportFilterSheet({required this.custom});

  final bool custom;

  @override
  State<_ReportFilterSheet> createState() => _ReportFilterSheetState();
}

class _ReportFilterSheetState extends State<_ReportFilterSheet> {
  String currency = 'all';
  String type = 'all';
  String? phone;
  DateTime? from;
  DateTime? to;
  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          12,
          22,
          MediaQuery.viewInsetsOf(context).bottom + 22,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetCloseButton(onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 10),
              Text(l10n.choose(ar: 'اختر الفلتر', en: 'Choose filters'),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              if (!widget.custom)
                _labeledDropdown(
                  title: l10n.choose(ar: 'العملة', en: 'Currency'),
                  value: currency,
                  options: [
                    (
                      'all',
                      l10n.choose(ar: 'كافة العملات', en: 'All currencies')
                    ),
                    ('YER', 'YER'),
                    ('USD', 'USD'),
                    ('SAR', 'SAR'),
                  ],
                  onChanged: (value) => setState(() => currency = value),
                ),
              _labeledDropdown(
                title: l10n.choose(ar: 'نوع العملية', en: 'Transaction type'),
                value: type,
                options: [
                  ('all', l10n.choose(ar: 'كافة الخدمات', en: 'All services')),
                  ('transfer', l10n.choose(ar: 'تحويل', en: 'Transfer')),
                  ('payment', l10n.choose(ar: 'دفع', en: 'Payment')),
                  ('topup', l10n.choose(ar: 'شحن', en: 'Top-up')),
                ],
                onChanged: (value) => setState(() => type = value),
              ),
              if (widget.custom) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText:
                        l10n.choose(ar: 'رقم الموبايل', en: 'Mobile number'),
                    prefixIcon: const Icon(Icons.contact_phone_outlined),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _dateField(
                label: l10n.choose(ar: 'من', en: 'From'),
                value: from,
                onTap: () => _pickDate(isFrom: true),
              ),
              const SizedBox(height: 12),
              _dateField(
                label: l10n.choose(ar: 'إلى', en: 'To'),
                value: to,
                onTap: () => _pickDate(isFrom: false),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    final parts = <String>[];
                    if (currency != 'all') parts.add(currency);
                    if (type != 'all') parts.add(type);
                    if (phoneController.text.trim().isNotEmpty) {
                      parts.add(phoneController.text.trim());
                    }
                    if (from != null || to != null) {
                      parts.add('${_formatDate(from)} - ${_formatDate(to)}');
                    }
                    Navigator.pop(
                      context,
                      parts.isEmpty
                          ? MadadLocalizations.of(context).choose(
                              ar: 'كافة العمليات', en: 'All transactions')
                          : parts.join(' · '),
                    );
                  },
                  child: Text(l10n.choose(ar: 'استمرار', en: 'Continue')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labeledDropdown({
    required String title,
    required String value,
    required List<(String, String)> options,
    required ValueChanged<String> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(labelText: title),
          items: [
            for (final option in options)
              DropdownMenuItem(value: option.$1, child: Text(option.$2)),
          ],
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      );

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MadadRadius.field),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_month_outlined),
          ),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              value == null ? ' ' : _formatDate(value),
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: MadadColors.textPrimary),
            ),
          ),
        ),
      );

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? from : to) ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          from = picked;
        } else {
          to = picked;
        }
      });
    }
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.close_rounded, size: 32),
        ),
      );
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
