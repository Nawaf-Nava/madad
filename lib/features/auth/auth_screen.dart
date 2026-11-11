import 'package:flutter/material.dart';

import '../../core/l10n/madad_localizations.dart';
import '../../core/theme/madad_theme.dart';
import '../../core/widgets/madad_brand_mark.dart';
import '../../core/widgets/madad_ui.dart';
import '../../data/madad_app_scope.dart';

enum _AuthView { welcome, login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final phoneC = TextEditingController();
  final pinC = TextEditingController();
  final firstNameC = TextEditingController();
  final secondNameC = TextEditingController();
  final thirdNameC = TextEditingController();
  final lastNameC = TextEditingController();
  final emailC = TextEditingController();
  _AuthView view = _AuthView.welcome;
  bool isSubmitting = false;
  bool acceptedTerms = false;
  bool obscurePassword = true;
  String gender = 'male';
  String countryCode = '+967';
  String? errorMessage;

  bool get isRegister => view == _AuthView.register;

  @override
  void dispose() {
    phoneC.dispose();
    pinC.dispose();
    firstNameC.dispose();
    secondNameC.dispose();
    thirdNameC.dispose();
    lastNameC.dispose();
    emailC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    if (view == _AuthView.welcome) return _welcome(l10n);
    final auth = MadadAppScope.of(context).auth;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.choose(ar: 'رجوع', en: 'Back'),
          onPressed: () => setState(() {
            view = _AuthView.welcome;
            errorMessage = null;
          }),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: l10n.text('language'),
            onPressed: _chooseLanguage,
            icon: const Icon(Icons.language_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _brandBanner(),
              const SizedBox(height: 26),
              Text(
                isRegister
                    ? l10n.choose(
                        ar: 'مرحباً بك في مَدَد', en: 'Welcome to MADAD')
                    : l10n.text('signInTitle'),
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: MadadColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isRegister
                    ? l10n.choose(
                        ar: 'قم بإنشاء حسابك وانضم إلى عملاء مَدَد',
                        en: 'Create your account and join MADAD',
                      )
                    : l10n.text('signInSubtitle'),
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: MadadColors.textPrimary, fontSize: 16),
              ),
              if (isRegister) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.choose(
                    ar: '* أدخل الاسم كما في الهوية',
                    en: '* Enter your name as shown on your ID',
                  ),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: MadadColors.orange,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                        child: _nameField(
                            secondNameC,
                            l10n.choose(
                                ar: 'الاسم الثاني', en: 'Second name'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _nameField(firstNameC,
                            l10n.choose(ar: 'الاسم الأول', en: 'First name'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _nameField(lastNameC,
                            l10n.choose(ar: 'اللقب', en: 'Family name'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _nameField(thirdNameC,
                            l10n.choose(ar: 'الاسم الثالث', en: 'Third name'))),
                  ],
                ),
                const SizedBox(height: 12),
              ] else ...[
                const SizedBox(height: 22),
              ],
              if (isRegister)
                Row(
                  children: [
                    SizedBox(
                      width: 118,
                      child: DropdownButtonFormField<String>(
                        initialValue: countryCode,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 16)),
                        items: const [
                          DropdownMenuItem(
                              value: '+967', child: Text('🇾🇪 +967')),
                          DropdownMenuItem(
                              value: '+966', child: Text('🇸🇦 +966')),
                          DropdownMenuItem(
                              value: '+971', child: Text('🇦🇪 +971')),
                        ],
                        onChanged: (value) {
                          if (value != null)
                            setState(() => countryCode = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _phoneField(l10n)),
                  ],
                )
              else
                _phoneField(l10n),
              const SizedBox(height: 12),
              TextField(
                controller: pinC,
                obscureText: obscurePassword,
                textInputAction:
                    isRegister ? TextInputAction.next : TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.text('pin'),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: obscurePassword
                        ? l10n.choose(
                            ar: 'إظهار كلمة المرور', en: 'Show password')
                        : l10n.choose(
                            ar: 'إخفاء كلمة المرور', en: 'Hide password'),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                    icon: Icon(obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
              ),
              if (isRegister) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.choose(
                      ar: '8 أحرف على الأقل', en: 'At least 8 characters'),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: MadadColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _genderOption(l10n.choose(ar: 'ذكر', en: 'Male'),
                            'male', Icons.person_outline_rounded)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _genderOption(
                            l10n.choose(ar: 'أنثى', en: 'Female'),
                            'female',
                            Icons.person_2_outlined)),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: acceptedTerms,
                  onChanged: (value) => setState(() {
                    acceptedTerms = value ?? false;
                    errorMessage = null;
                  }),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.choose(
                        ar: 'أوافق على الشروط والأحكام',
                        en: 'I agree to the terms and conditions'),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        color: MadadColors.textPrimary,
                        fontWeight: FontWeight.w700),
                  ),
                  subtitle: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: _showTerms,
                      child: Text(
                          l10n.choose(ar: 'قراءة الشروط', en: 'Read terms')),
                    ),
                  ),
                ),
              ],
              if (errorMessage != null || auth.errorMessage != null) ...[
                const SizedBox(height: 10),
                MadadNotice(
                  icon: Icons.error_outline_rounded,
                  message: errorMessage ?? auth.errorMessage!,
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: isSubmitting || auth.isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58)),
                child: isSubmitting || auth.isLoading
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        isRegister
                            ? l10n.choose(
                                ar: 'إنشاء حساب', en: 'Create account')
                            : l10n.text('signIn'),
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800),
                      ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isSubmitting || auth.isLoading
                    ? null
                    : () => setState(() {
                          view =
                              isRegister ? _AuthView.login : _AuthView.register;
                          errorMessage = null;
                        }),
                child: Text(isRegister
                    ? l10n.choose(
                        ar: 'لديك حساب بالفعل؟ تسجيل الدخول',
                        en: 'Already have an account? Sign in')
                    : l10n.choose(
                        ar: 'مستخدم جديد؟ إنشاء حساب',
                        en: 'New user? Create an account')),
              ),
              if (isRegister) ...[
                const SizedBox(height: 8),
                _contactLinks(l10n),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcome(MadadLocalizations l10n) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Tooltip(
                      message: l10n.text('language'),
                      child: TextButton.icon(
                        onPressed: _chooseLanguage,
                        icon: const Icon(Icons.language_rounded),
                        label: Text(l10n.choose(
                            ar: 'لغة التطبيق  عربي',
                            en: 'App language  English')),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      const Positioned.fill(child: _BrandPattern()),
                      Align(
                        alignment: const Alignment(0, -.5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const MadadLogoLockup(markSize: 88),
                            const SizedBox(height: 40),
                            Text(
                              l10n.choose(
                                  ar: 'كل ما تحتاجه مَدَد',
                                  en: 'Everything you need, MADAD'),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: MadadColors.orange,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.choose(ar: 'ابدأ الآن!', en: 'Get started!'),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: MadadColors.textPrimary,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.choose(
                                  ar: 'نظّم جميع حركاتك المالية\nبكل سهولة',
                                  en: 'Organize your financial activity\nwith ease'),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: MadadColors.textPrimary,
                                  fontSize: 20,
                                  height: 1.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => setState(() => view = _AuthView.login),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58)),
                  child: Text(l10n.text('signIn'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => setState(() {
                    view = _AuthView.register;
                    acceptedTerms = false;
                  }),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: Colors.white,
                    foregroundColor: MadadColors.background,
                    side: BorderSide.none,
                  ),
                  child: Text(
                      l10n.choose(ar: 'قم بإنشاء الحساب', en: 'Create account'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 24),
                _contactLinks(l10n),
              ],
            ),
          ),
        ),
      );

  Widget _brandBanner() => SizedBox(
        height: 112,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(child: _BrandPattern()),
            const MadadLogoLockup(markSize: 70),
          ],
        ),
      );

  Widget _nameField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        textAlign: TextAlign.end,
        decoration: InputDecoration(labelText: label),
      );

  Widget _phoneField(MadadLocalizations l10n) => TextField(
        controller: phoneC,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: l10n.text('phoneNumber'),
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
      );

  Widget _genderOption(String label, String value, IconData icon) {
    final selected = gender == value;
    return Material(
      color: selected ? MadadColors.orangeSurface : MadadColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => gender = value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected
                      ? MadadColors.orange
                      : MadadColors.textSecondary),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: MadadColors.textPrimary,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactLinks(MadadLocalizations l10n) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _contactItem(Icons.chat_bubble_outline_rounded,
              l10n.choose(ar: 'خدمة العملاء', en: 'Support')),
          _contactItem(Icons.location_on_outlined,
              l10n.choose(ar: 'نقاط الخدمة', en: 'Locations')),
          _contactItem(Icons.call_outlined,
              l10n.choose(ar: 'الرقم المجاني', en: 'Free call')),
        ],
      );

  Widget _contactItem(IconData icon, String label) => Flexible(
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                border: Border.all(color: MadadColors.textSecondary),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: MadadColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: MadadColors.textSecondary, fontSize: 11)),
          ],
        ),
      );

  Future<void> _submit() async {
    final l10n = MadadLocalizations.of(context);
    final auth = MadadAppScope.of(context).auth;
    final phone = phoneC.text.trim();
    final password = pinC.text;
    final fullName = [
      firstNameC.text,
      secondNameC.text,
      thirdNameC.text,
      lastNameC.text,
    ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(' ');
    if (phone.isEmpty ||
        password.isEmpty ||
        (isRegister && fullName.length < 2)) {
      setState(() => errorMessage = l10n.choose(
          ar: 'أكمل الحقول المطلوبة.', en: 'Complete the required fields.'));
      return;
    }
    if (isRegister && !acceptedTerms) {
      setState(() => errorMessage = l10n.choose(
          ar: 'يرجى الموافقة على الشروط والأحكام.',
          en: 'Please accept the terms and conditions.'));
      return;
    }
    if (isRegister && password.length < 8) {
      setState(() => errorMessage = l10n.choose(
          ar: 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.',
          en: 'Password must be at least 8 characters.'));
      return;
    }
    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });
    try {
      final normalizedPhone =
          isRegister && !phone.startsWith('+') ? '$countryCode$phone' : phone;
      if (isRegister) {
        await auth.register(
          phone: normalizedPhone,
          fullName: fullName,
          password: password,
          email: emailC.text.trim().isEmpty ? null : emailC.text.trim(),
        );
      } else {
        await auth.login(phone: phone, password: password);
      }
    } catch (error) {
      if (mounted) setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _showTerms() async {
    final l10n = MadadLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded)),
                    Expanded(
                        child: Text(
                            l10n.choose(
                                ar: 'الشروط والأحكام',
                                en: 'Terms and conditions'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge)),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
                  children: [
                    Text(
                        l10n.choose(
                            ar: 'يرجى قراءة المعلومات التالية قبل إنشاء حسابك.',
                            en: 'Please review this information before creating your account.'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    for (final section in _termsSections(l10n)) ...[
                      Text(section.$1,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: MadadColors.orange,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 7),
                      Text(section.$2,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: MadadColors.textPrimary, height: 1.7)),
                      const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: FilledButton(
                  onPressed: () {
                    setState(() => acceptedTerms = true);
                    Navigator.pop(context);
                  },
                  child: Text(l10n.choose(ar: 'موافق', en: 'Accept')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<(String, String)> _termsSections(MadadLocalizations l10n) => [
        (
          l10n.choose(
              ar: 'حساب المحفظة الإلكترونية', en: 'Electronic wallet account'),
          l10n.choose(
              ar: 'الحساب وسيلة لإدارة الخدمات المالية المتاحة من خلال مَدَد. إنشاء الحساب لا يعني إيداع أموال أو ضمان توفر جميع الخدمات.',
              en: 'The account provides access to financial services made available through MADAD. Registration does not deposit funds or guarantee that every service is available.'),
        ),
        (
          l10n.choose(
              ar: 'البيانات والتحقق', en: 'Information and verification'),
          l10n.choose(
              ar: 'قد نطلب معلومات إضافية للتحقق من الهوية وفق متطلبات الجهات المرخصة. يجب أن تكون البيانات المقدمة دقيقة ومحدثة.',
              en: 'Additional information may be requested for identity verification under applicable provider requirements. Submitted information should be accurate and current.'),
        ),
        (
          l10n.choose(ar: 'العمليات والرسوم', en: 'Transactions and fees'),
          l10n.choose(
              ar: 'تخضع العمليات والرسوم والحدود لتوفر مزود الخدمة وشروطه. راجع تفاصيل أي عملية قبل تأكيدها، ولا تشارك كلمة المرور أو رموز التحقق.',
              en: 'Transactions, fees, and limits depend on provider availability and terms. Review transaction details before confirmation and never share your password or verification codes.'),
        ),
        (
          l10n.choose(ar: 'أمان الحساب', en: 'Account security'),
          l10n.choose(
              ar: 'أنت مسؤول عن حماية بيانات الدخول وإبلاغ الدعم عند الاشتباه باستخدام غير مصرح به. قد تتوقف بعض الخدمات للصيانة أو لأسباب تنظيمية.',
              en: 'You are responsible for protecting your sign-in details and contacting support if you suspect unauthorized access. Services may be unavailable for maintenance or regulatory reasons.'),
        ),
      ];

  Future<void> _chooseLanguage() async {
    final l10n = MadadLocalizations.of(context);
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.text('chooseLanguage'),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ListTile(
                  leading: const Icon(Icons.translate_rounded),
                  title: Text(l10n.text('arabic')),
                  onTap: () => Navigator.pop(context, const Locale('ar'))),
              ListTile(
                  leading: const Icon(Icons.translate_rounded),
                  title: Text(l10n.text('english')),
                  onTap: () => Navigator.pop(context, const Locale('en'))),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      MadadLocaleController.of(context).onLocaleChanged(selected);
    }
  }
}

class _BrandPattern extends StatelessWidget {
  const _BrandPattern();

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _PatternPainter(),
        child: const SizedBox.expand(),
      );
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MadadColors.orange.withValues(alpha: .08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const stepX = 44.0;
    const stepY = 38.0;
    for (var y = 0.0; y < size.height; y += stepY) {
      for (var x = 0.0; x < size.width; x += stepX) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 5, y + 5, 15, 15),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, paint);
        canvas.drawCircle(Offset(x + 25, y + 25), 5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
