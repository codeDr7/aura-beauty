import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ar.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String>? _localizedStrings;

  Future<void> load() async {
    switch (locale.languageCode) {
      case 'ar':
        _localizedStrings = arabicTranslations;
        break;
      default:
        _localizedStrings = englishTranslations;
        break;
    }
  }

  String translate(String key, {List<String>? params}) {
    String? text = _localizedStrings![key];
    if (text == null) {
      return '** $key **';
    }
    if (params != null) {
      for (int i = 0; i < params.length; i++) {
        text = text!.replaceAll('{$i}', params[i]);
      }
    }
    return text!;
  }

  String plural(String key, int count, {List<String>? params}) {
    final pluralKey = '${key}_${_pluralForm(count)}';
    String? text = _localizedStrings![pluralKey];
    if (text == null) {
      text = _localizedStrings!['${key}_other'];
    }
    if (text == null) {
      text = _localizedStrings![key];
    }
    if (text == null) {
      return '** $key **';
    }
    text = text.replaceAll('{count}', count.toString());
    if (params != null) {
      for (int i = 0; i < params.length; i++) {
        text = text.replaceAll('{$i}', params[i]);
      }
    }
    return text;
  }

  String _pluralForm(int count) {
    if (locale.languageCode == 'ar') {
      if (count == 0) return 'zero';
      if (count == 1) return 'one';
      if (count == 2) return 'two';
      if (count > 2 && count <= 10) return 'few';
      return 'other';
    }
    if (count == 1) return 'one';
    return 'other';
  }

  bool get isRtl => locale.languageCode == 'ar';

  // Common
  String get appName => translate('appName');
  String get appFullName => translate('appFullName');
  String get welcome => translate('welcome');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get next => translate('next');
  String get back => translate('back');
  String get done => translate('done');
  String get skip => translate('skip');
  String get noInternet => translate('noInternet');
  String get unexpectedError => translate('unexpectedError');
  String get tryAgain => translate('tryAgain');
  String get noData => translate('noData');

  // Auth
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get forgotPassword => translate('forgotPassword');
  String get resetPassword => translate('resetPassword');
  String get createAccount => translate('createAccount');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get signInGoogle => translate('signInGoogle');
  String get signInApple => translate('signInApple');
  String get orContinueWith => translate('orContinueWith');
  String get rememberMe => translate('rememberMe');
  String get enterEmail => translate('enterEmail');
  String get enterPassword => translate('enterPassword');
  String get passwordHint => translate('passwordHint');
  String get fullName => translate('fullName');
  String get phoneNumber => translate('phoneNumber');
  String get dateOfBirth => translate('dateOfBirth');
  String get sendResetLink => translate('sendResetLink');
  String get checkEmail => translate('checkEmail');
  String get resetLinkSent => translate('resetLinkSent');
  String get logout => translate('logout');

  // Onboarding
  String get personalInfo => translate('personalInfo');
  String get skinAssessment => translate('skinAssessment');
  String get hairAssessment => translate('hairAssessment');
  String get lifestyleAssessment => translate('lifestyleAssessment');
  String get assessmentResults => translate('assessmentResults');
  String get tellUsAboutYourself => translate('tellUsAboutYourself');
  String get letsAssessSkin => translate('letsAssessSkin');
  String get letsAssessHair => translate('letsAssessHair');
  String get letsAssessLifestyle => translate('letsAssessLifestyle');
  String get yourResults => translate('yourResults');
  String get selectAllThatApply => translate('selectAllThatApply');
  String get chooseOne => translate('chooseOne');
  String get assessing => translate('assessing');
  String get generatingResults => translate('generatingResults');

  // Home
  String get goodMorning => translate('goodMorning');
  String get goodAfternoon => translate('goodAfternoon');
  String get goodEvening => translate('goodEvening');
  String get skinScore => translate('skinScore');
  String get hairScore => translate('hairScore');
  String get todaysRoutine => translate('todaysRoutine');
  String get quickActions => translate('quickActions');
  String get askAiCoach => translate('askAiCoach');
  String get dailyTip => translate('dailyTip');
  String get streakDays => translate('streakDays');
  String get completeRoutine => translate('completeRoutine');
  String get viewAll => translate('viewAll');
  String get recentActivity => translate('recentActivity');

  // Discover
  String get discover => translate('discover');
  String get products => translate('products');
  String get ingredients => translate('ingredients');
  String get guides => translate('guides');
  String get trending => translate('trending');
  String get newArrivals => translate('newArrivals');
  String get recommended => translate('recommended');
  String get categories => translate('categories');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get ingredientAnalyzer => translate('ingredientAnalyzer');
  String get scanProduct => translate('scanProduct');

  // Community
  String get feed => translate('feed');
  String get groups => translate('groups');
  String get challenges => translate('challenges');
  String get createPost => translate('createPost');
  String get joinGroup => translate('joinGroup');
  String get leaveGroup => translate('leaveGroup');
  String get startChallenge => translate('startChallenge');
  String get joinChallenge => translate('joinChallenge');
  String get likes => translate('likes');
  String get comments => translate('comments');
  String get shares => translate('shares');
  String get postYourThoughts => translate('postYourThoughts');
  String get trendingPosts => translate('trendingPosts');
  String get groupRules => translate('groupRules');
  String get members => translate('members');

  // Progress
  String get timeline => translate('timeline');
  String get statistics => translate('statistics');
  String get charts => translate('charts');
  String get skinProgress => translate('skinProgress');
  String get hairProgress => translate('hairProgress');
  String get overallScore => translate('overallScore');
  String get thisWeek => translate('thisWeek');
  String get thisMonth => translate('thisMonth');
  String get thisYear => translate('thisYear');
  String get comparison => translate('comparison');
  String get achievements => translate('achievements');
  String get milestones => translate('milestones');
  String get consistency => translate('consistency');
  String get improvement => translate('improvement');

  // Profile
  String get myProfile => translate('myProfile');
  String get subscription => translate('subscription');
  String get settings => translate('settings');
  String get editProfile => translate('editProfile');
  String get myRoutines => translate('myRoutines');
  String get savedProducts => translate('savedProducts');
  String get beautyProfile => translate('beautyProfile');
  String get reassessSkin => translate('reassessSkin');
  String get accountSettings => translate('accountSettings');
  String get notificationSettings => translate('notificationSettings');
  String get privacySettings => translate('privacySettings');
  String get helpSupport => translate('helpSupport');
  String get aboutApp => translate('aboutApp');
  String get version => translate('version');
  String get deleteAccount => translate('deleteAccount');

  // AI Coach
  String get aiCoach => translate('aiCoach');
  String get aiCoachPlaceholder => translate('aiCoachPlaceholder');
  String get send => translate('send');
  String get typeMessage => translate('typeMessage');
  String get aiThinking => translate('aiThinking');
  String get askBeautyQuestion => translate('askBeautyQuestion');
  String get suggestedQuestions => translate('suggestedQuestions');
  String get clearChat => translate('clearChat');
  String get chatHistory => translate('chatHistory');

  // Routines
  String get morningRoutine => translate('morningRoutine');
  String get eveningRoutine => translate('eveningRoutine');
  String get weeklyRoutine => translate('weeklyRoutine');
  String get hairRoutine => translate('hairRoutine');
  String get addToRoutine => translate('addToRoutine');
  String get removeFromRoutine => translate('removeFromRoutine');
  String get stepCompleted => translate('stepCompleted');
  String get routineProgress => translate('routineProgress');
  String get customizeRoutine => translate('customizeRoutine');
  String get recommendedForYou => translate('recommendedForYou');

  // Products
  String get productPrice => translate('productPrice');
  String get compatibility => translate('compatibility');
  String get productDetails => translate('productDetails');
  String get ingredientsList => translate('ingredientsList');
  String get howToUse => translate('howToUse');
  String get reviews => translate('reviews');
  String get rating => translate('rating');
  String get similarProducts => translate('similarProducts');
  String get addToCart => translate('addToCart');
  String get buyNow => translate('buyNow');
  String get inRoutine => translate('inRoutine');
  String get notCompatible => translate('notCompatible');
  String get partiallyCompatible => translate('partiallyCompatible');
  String get fullyCompatible => translate('fullyCompatible');

  // Settings
  String get notifications => translate('notifications');
  String get privacy => translate('privacy');
  String get language => translate('language');
  String get theme => translate('theme');
  String get about => translate('about');
  String get lightMode => translate('lightMode');
  String get darkMode => translate('darkMode');
  String get systemMode => translate('systemMode');
  String get pushNotifications => translate('pushNotifications');
  String get emailNotifications => translate('emailNotifications');
  String get routineReminders => translate('routineReminders');
  String get privacyPolicy => translate('privacyPolicy');
  String get termsOfService => translate('termsOfService');
  String get changePassword => translate('changePassword');
  String get dataUsage => translate('dataUsage');
  String get deleteData => translate('deleteData');
  String get appVersion => translate('appVersion');

  // Subscription
  String get free => translate('free');
  String get plus => translate('plus');
  String get premium => translate('premium');
  String get upgrade => translate('upgrade');
  String get currentPlan => translate('currentPlan');
  String get perMonth => translate('perMonth');
  String get perYear => translate('perYear');
  String get mostPopular => translate('mostPopular');
  String get subscribeNow => translate('subscribeNow');
  String get cancelAnytime => translate('cancelAnytime');
  String get includesAllPrevious => translate('includesAllPrevious');
  String get planFeatures => translate('planFeatures');
  String get comparePlans => translate('comparePlans');
  String get paymentMethod => translate('paymentMethod');
  String get manageSubscription => translate('manageSubscription');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
