import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MadadLocalizations {
  const MadadLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('ar'), Locale('en')];

  static MadadLocalizations of(BuildContext context) =>
      Localizations.of<MadadLocalizations>(context, MadadLocalizations)!;

  bool get isArabic => locale.languageCode == 'ar';

  String text(String key) => (isArabic ? _arabic : _english)[key] ?? key;

  String choose({required String ar, required String en}) => isArabic ? ar : en;

  static const _arabic = <String, String>{
    'appName': 'مَدَد',
    'tagline': 'محفظتك المالية الذكية والآمنة',
    'signInTitle': 'مرحباً بعودتك',
    'signInSubtitle': 'سجّل الدخول إلى حساب مَدَد',
    'phoneNumber': 'رقم الهاتف المحمول',
    'pin': 'كلمة المرور',
    'signIn': 'تسجيل الدخول',
    'demoMode': 'الوضع التجريبي الآمن',
    'home': 'الرئيسية',
    'transactions': 'المعاملات',
    'services': 'الخدمات',
    'profile': 'حسابي',
    'notifications': 'الإشعارات',
    'greeting': 'مرحباً بك مجدداً',
    'dashboardSubtitle': 'كل احتياجاتك المالية في مكان واحد',
    'quickServices': 'الخدمات السريعة',
    'transfer': 'تحويل',
    'payment': 'دفع',
    'topUp': 'شحن',
    'seeAll': 'عرض الكل',
    'walletBalance': 'رصيد المحفظة',
    'balanceUnavailable': 'غير متاح حالياً',
    'balanceUnavailableHint': 'يظهر الرصيد بعد الاتصال بحسابك',
    'sendMoney': 'إرسال أموال',
    'addFunds': 'إضافة رصيد',
    'recentTransactions': 'آخر المعاملات',
    'noTransactions': 'لا توجد معاملات',
    'demoNotice':
        'الميزات المعروضة غير متصلة بمزود مالي ولا تنفذ عمليات حقيقية.',
    'accountSettings': 'إعدادات الحساب',
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'الإنجليزية',
    'chooseLanguage': 'اختيار اللغة',
    'personalDetails': 'البيانات الشخصية',
    'verification': 'توثيق الحساب',
    'securityPrivacy': 'الأمان والخصوصية',
    'beneficiaries': 'المستفيدون والمفضلة',
    'helpSupport': 'المساعدة والدعم',
    'close': 'إغلاق',
    'qrScanner': 'ماسح QR',
    'cameraUnavailable': 'معاينة الكاميرا غير متاحة',
    'importImage': 'استيراد صورة',
  };

  static const _english = <String, String>{
    'appName': 'MADAD',
    'tagline': 'Your smart and secure wallet',
    'signInTitle': 'Welcome back',
    'signInSubtitle': 'Sign in to your MADAD account',
    'phoneNumber': 'Mobile number',
    'pin': 'Password',
    'signIn': 'Sign in',
    'demoMode': 'Secure demo mode',
    'home': 'Home',
    'transactions': 'Transactions',
    'services': 'Services',
    'profile': 'Profile',
    'notifications': 'Notifications',
    'greeting': 'Welcome back',
    'dashboardSubtitle': 'Your financial services in one place',
    'quickServices': 'Quick services',
    'transfer': 'Transfer',
    'payment': 'Pay',
    'topUp': 'Top up',
    'seeAll': 'See all',
    'walletBalance': 'Wallet balance',
    'balanceUnavailable': 'Currently unavailable',
    'balanceUnavailableHint':
        'Your balance appears when your account is connected',
    'sendMoney': 'Send money',
    'addFunds': 'Add funds',
    'recentTransactions': 'Recent transactions',
    'noTransactions': 'No transactions',
    'demoNotice':
        'Displayed features are not connected to a financial provider and do not perform real transactions.',
    'accountSettings': 'Account settings',
    'language': 'Language',
    'arabic': 'Arabic',
    'english': 'English',
    'chooseLanguage': 'Choose language',
    'personalDetails': 'Personal details',
    'verification': 'Account verification',
    'securityPrivacy': 'Security and privacy',
    'beneficiaries': 'Beneficiaries and favorites',
    'helpSupport': 'Help and support',
    'close': 'Close',
    'qrScanner': 'QR scanner',
    'cameraUnavailable': 'Camera preview unavailable',
    'importImage': 'Import image',
  };

  static const LocalizationsDelegate<MadadLocalizations> delegate =
      _MadadLocalizationsDelegate();
}

class _MadadLocalizationsDelegate
    extends LocalizationsDelegate<MadadLocalizations> {
  const _MadadLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => MadadLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<MadadLocalizations> load(Locale locale) =>
      SynchronousFuture(MadadLocalizations(locale));

  @override
  bool shouldReload(_MadadLocalizationsDelegate old) => false;
}

class MadadLocaleController extends InheritedWidget {
  const MadadLocaleController({
    required this.onLocaleChanged,
    required super.child,
    super.key,
  });

  final ValueChanged<Locale> onLocaleChanged;

  static MadadLocaleController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MadadLocaleController>()!;

  @override
  bool updateShouldNotify(MadadLocaleController oldWidget) =>
      onLocaleChanged != oldWidget.onLocaleChanged;
}
