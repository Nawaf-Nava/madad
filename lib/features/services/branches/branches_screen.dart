import 'package:flutter/material.dart';

import '../../../core/l10n/madad_localizations.dart';
import '../../../core/widgets/madad_ui.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title:
            Text(l10n.choose(ar: 'الوكلاء والفروع', en: 'Agents and branches')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadPageHeader(
            title: l10n.choose(ar: 'نقاط الخدمة', en: 'Service locations'),
            subtitle: l10n.choose(
              ar: 'تتطلب القائمة بيانات فروع موثقة ومتصلة.',
              en: 'The directory requires verified, connected branch data.',
            ),
            icon: Icons.location_on_outlined,
          ),
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.choose(
                  ar: 'ابحث عن مدينة أو فرع', en: 'Search city or branch'),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.choose(ar: 'مسح البحث', en: 'Clear search'),
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          MadadNotice(
            icon: Icons.verified_outlined,
            message: l10n.choose(
              ar: 'لا توجد قائمة مواقع موثقة متصلة في هذه النسخة. لم يتم تحديد موقع على خريطة.',
              en: 'No verified location directory is connected in this build. No map location was set.',
            ),
          ),
          SizedBox(
            height: 330,
            child: MadadEmptyState(
              icon: Icons.location_off_outlined,
              title: l10n.choose(
                  ar: 'لا توجد فروع متاحة', en: 'No branches available'),
              message: l10n.choose(
                ar: 'ستظهر المواقع بعد ربط مصدر فروع موثوق.',
                en: 'Locations will appear after a trusted branch source is connected.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
