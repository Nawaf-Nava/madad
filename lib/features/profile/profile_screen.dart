import 'package:flutter/material.dart';

import '../../core/l10n/madad_localizations.dart';
import '../../core/theme/madad_theme.dart';
import '../../core/widgets/madad_ui.dart';
import '../../data/madad_app_scope.dart';
import '../account/account_tools_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  Object? error;
  bool isLoading = true;
  bool isSaving = false;
  bool isLoggingOut = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await MadadAppScope.of(context).repository.getProfile();
      if (mounted) setState(() => profile = result);
    } catch (exception) {
      if (mounted) setState(() => error = exception);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    final sessionUser = MadadAppScope.of(context).auth.session?.user ??
        const <String, dynamic>{};
    final user = profile ?? sessionUser;
    final fullName = user['fullName'] as String? ?? '';
    final phone = user['phone'] as String? ?? '';
    final email = user['email'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        MadadPageHeader(
          title: l10n.text('profile'),
          subtitle: l10n.choose(
            ar: 'بيانات الحساب المحفوظة في خادم مَدَد.',
            en: 'Account details stored by the MADAD server.',
          ),
          icon: Icons.person_outline_rounded,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: MadadColors.orangeSurface,
                  child: Icon(Icons.person_outline_rounded,
                      color: MadadColors.orange, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName.isEmpty ? l10n.text('profile') : fullName,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text(
                        phone.isEmpty
                            ? l10n.choose(
                                ar: 'لا يوجد حساب متصل',
                                en: 'No connected account',
                              )
                            : phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (email.isNotEmpty)
                        Text(email,
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip:
                      l10n.choose(ar: 'تعديل البيانات', en: 'Edit details'),
                  onPressed: isLoading || isSaving ? null : _editProfile,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 18),
          const LinearProgressIndicator(),
        ] else if (error != null) ...[
          const SizedBox(height: 14),
          MadadNotice(
            icon: Icons.cloud_off_outlined,
            message: l10n.choose(
              ar: 'تعذر تحديث الملف الشخصي من الخادم. البيانات المعروضة إن وجدت هي آخر بيانات جلسة محفوظة.',
              en: 'Could not refresh the profile. Any displayed details are from the signed-in session.',
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.choose(ar: 'إعادة المحاولة', en: 'Retry')),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _item(
          context,
          Icons.person_outline,
          l10n.text('personalDetails'),
          l10n.choose(
              ar: 'تعديل الاسم والبريد الإلكتروني', en: 'Edit name and email'),
          onTap: _editProfile,
        ),
        _item(
          context,
          Icons.verified_user_outlined,
          l10n.text('verification'),
          l10n.choose(
              ar: 'يتطلب مزود هوية معتمداً.',
              en: 'Requires an authorized identity provider.'),
        ),
        _item(
          context,
          Icons.notifications_outlined,
          l10n.text('notifications'),
          l10n.choose(
              ar: 'تفضيلات الإشعارات المحلية.',
              en: 'Local notification preferences.'),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.fingerprint, color: MadadColors.orange),
            title: Text(l10n.text('securityPrivacy')),
            subtitle: Text(l10n.choose(
                ar: 'إعدادات محلية للواجهة', en: 'Local UI settings')),
            trailing: _directionalChevron(context),
            onTap: () => Navigator.push(
              context,
              madadPageRoute(const AccountToolsScreen()),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading:
                const Icon(Icons.contacts_outlined, color: MadadColors.orange),
            title: Text(l10n.choose(
                ar: 'المستفيدون والمفضلة', en: 'Beneficiaries and favorites')),
            subtitle: Text(l10n.choose(
                ar: 'أسماء محلية على هذا الجهاز.',
                en: 'Names saved locally on this device.')),
            trailing: _directionalChevron(context),
            onTap: () => Navigator.push(
              context,
              madadPageRoute(const AccountToolsScreen()),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language, color: MadadColors.orange),
            title: Text(l10n.text('language')),
            subtitle: Text(
                l10n.isArabic ? l10n.text('arabic') : l10n.text('english')),
            trailing: _directionalChevron(context),
            onTap: () => _chooseLanguage(context, l10n),
          ),
        ),
        _item(
          context,
          Icons.help_outline,
          l10n.text('helpSupport'),
          l10n.choose(
              ar: 'لا توجد قناة دعم متصلة في هذه النسخة.',
              en: 'No support channel is connected in this build.'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isLoggingOut ? null : _logout,
          icon: isLoggingOut
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_rounded),
          label: Text(l10n.choose(ar: 'تسجيل الخروج', en: 'Sign out')),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            l10n.choose(
                ar: 'مَدَد • معاينة مستقلة', en: 'MADAD • Independent preview'),
            style: const TextStyle(color: MadadColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) =>
      Card(
        child: ListTile(
          leading: Icon(icon, color: MadadColors.orange),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: _directionalChevron(context),
          onTap: onTap ?? () => _message(context, title, subtitle),
        ),
      );

  Widget _directionalChevron(BuildContext context) => Icon(
        Directionality.of(context) == TextDirection.rtl
            ? Icons.chevron_left
            : Icons.chevron_right,
      );

  Future<void> _editProfile() async {
    final l10n = MadadLocalizations.of(context);
    final name = TextEditingController(
      text: (profile?['fullName'] as String?) ??
          (MadadAppScope.of(context).auth.session?.user['fullName']
                  as String? ??
              ''),
    );
    final email =
        TextEditingController(text: profile?['email'] as String? ?? '');
    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.text('personalDetails')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(
                  labelText: l10n.choose(ar: 'الاسم الكامل', en: 'Full name')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: l10n.choose(ar: 'البريد الإلكتروني', en: 'Email')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.choose(ar: 'إلغاء', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, {
              'fullName': name.text.trim(),
              'email': email.text.trim(),
            }),
            child: Text(l10n.choose(ar: 'حفظ', en: 'Save')),
          ),
        ],
      ),
    );
    name.dispose();
    email.dispose();
    if (values == null || !mounted) return;

    setState(() => isSaving = true);
    try {
      final updated = await MadadAppScope.of(context).repository.updateProfile(
            fullName: values['fullName'],
            email: values['email'],
          );
      if (mounted) setState(() => profile = updated);
    } catch (exception) {
      if (mounted) {
        _message(context, l10n.choose(ar: 'تعذر الحفظ', en: 'Could not save'),
            exception.toString());
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _logout() async {
    setState(() => isLoggingOut = true);
    try {
      await MadadAppScope.of(context).auth.logout();
    } catch (exception) {
      if (mounted) {
        final l10n = MadadLocalizations.of(context);
        _message(
            context,
            l10n.choose(
                ar: 'تعذر تسجيل الخروج من الخادم',
                en: 'Server sign-out failed'),
            exception.toString());
      }
    } finally {
      if (mounted) setState(() => isLoggingOut = false);
    }
  }

  void _message(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(MadadLocalizations.of(context).text('close')),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseLanguage(
      BuildContext context, MadadLocalizations l10n) async {
    final locale = await showModalBottomSheet<Locale>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.text('chooseLanguage'),
                style: Theme.of(context).textTheme.titleLarge),
            ListTile(
                title: Text(l10n.text('arabic')),
                onTap: () => Navigator.pop(context, const Locale('ar'))),
            ListTile(
                title: Text(l10n.text('english')),
                onTap: () => Navigator.pop(context, const Locale('en'))),
          ]),
        ),
      ),
    );
    if (locale != null && context.mounted) {
      MadadLocaleController.of(context).onLocaleChanged(locale);
    }
  }
}
