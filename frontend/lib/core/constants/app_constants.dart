class AppConstants {
  AppConstants._();

  static const String appName = 'Aura';
  static const String appFullName = 'Aura - Beauty Intelligence';
  static const String appVersion = '1.0.0';
  static const String appPackageName = 'com.aurabeauty.app';

  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);
  static const Duration debounceDuration = Duration(milliseconds: 300);
  static const Duration throttleDuration = Duration(milliseconds: 500);
  static const Duration cacheDuration = Duration(minutes: 15);

  static const int maxRetries = 3;
  static const int pageSize = 20;
  static const int maxImageSize = 5 * 1024 * 1024;
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1920;

  static const List<Map<String, dynamic>> skinTypeQuestions = [
    {
      'id': 'skin_feel',
      'question': 'How does your skin usually feel after cleansing?',
      'options': [
        {'label': 'Tight and dry', 'value': 'dry'},
        {'label': 'Comfortable and balanced', 'value': 'normal'},
        {'label': 'Oily within an hour', 'value': 'oily'},
        {'label': 'Oily on T-zone, dry on cheeks', 'value': 'combination'},
      ],
    },
    {
      'id': 'skin_concerns',
      'question': 'What are your primary skin concerns?',
      'multiple': true,
      'options': [
        {'label': 'Fine lines and wrinkles', 'value': 'aging'},
        {'label': 'Dark spots and hyperpigmentation', 'value': 'pigmentation'},
        {'label': 'Acne and breakouts', 'value': 'acne'},
        {'label': 'Redness and sensitivity', 'value': 'sensitivity'},
        {'label': 'Dullness and uneven texture', 'value': 'dullness'},
        {'label': 'Dehydration', 'value': 'dehydration'},
        {'label': 'Large pores', 'value': 'pores'},
      ],
    },
    {
      'id': 'skin_sensitivity',
      'question': 'How sensitive is your skin?',
      'options': [
        {'label': 'Very sensitive - reacts to most products', 'value': 'very'},
        {'label': 'Moderately sensitive - reacts occasionally', 'value': 'moderate'},
        {'label': 'Slightly sensitive - rare reactions', 'value': 'slight'},
        {'label': 'Not sensitive - tolerates all products', 'value': 'none'},
      ],
    },
    {
      'id': 'skin_environment',
      'question': 'What environment are you most often in?',
      'options': [
        {'label': 'Air-conditioned indoor', 'value': 'ac_indoor'},
        {'label': 'Humid outdoor climate', 'value': 'humid_outdoor'},
        {'label': 'Dry climate', 'value': 'dry_climate'},
        {'label': 'Polluted city environment', 'value': 'polluted'},
        {'label': 'Mixed environments', 'value': 'mixed'},
      ],
    },
  ];

  static const List<Map<String, dynamic>> hairTypeQuestions = [
    {
      'id': 'hair_type',
      'question': 'What is your hair type?',
      'options': [
        {'label': 'Straight (Type 1)', 'value': 'straight'},
        {'label': 'Wavy (Type 2)', 'value': 'wavy'},
        {'label': 'Curly (Type 3)', 'value': 'curly'},
        {'label': 'Coily (Type 4)', 'value': 'coily'},
      ],
    },
    {
      'id': 'hair_porosity',
      'question': 'How does your hair absorb moisture?',
      'options': [
        {'label': 'Repels water, takes long to wet', 'value': 'low'},
        {'label': 'Absorbs water easily, dries normally', 'value': 'medium'},
        {'label': 'Absorbs water instantly, dries quickly', 'value': 'high'},
      ],
    },
    {
      'id': 'hair_concerns',
      'question': 'What are your primary hair concerns?',
      'multiple': true,
      'options': [
        {'label': 'Hair loss and thinning', 'value': 'hair_loss'},
        {'label': 'Dryness and brittleness', 'value': 'dryness'},
        {'label': 'Frizz and flyaways', 'value': 'frizz'},
        {'label': 'Dandruff and scalp issues', 'value': 'dandruff'},
        {'label': 'Damage from heat or color', 'value': 'damage'},
        {'label': 'Slow growth', 'value': 'slow_growth'},
        {'label': 'Oily scalp', 'value': 'oily_scalp'},
      ],
    },
    {
      'id': 'hair_routine',
      'question': 'How often do you wash your hair?',
      'options': [
        {'label': 'Daily', 'value': 'daily'},
        {'label': 'Every 2-3 days', 'value': 'every_2_3'},
        {'label': 'Twice a week', 'value': 'twice_week'},
        {'label': 'Once a week', 'value': 'once_week'},
        {'label': 'Less than once a week', 'value': 'less_weekly'},
      ],
    },
  ];

  static const List<Map<String, dynamic>> lifestyleQuestions = [
    {
      'id': 'sleep_hours',
      'question': 'How many hours do you sleep on average?',
      'options': [
        {'label': 'Less than 5 hours', 'value': '<5'},
        {'label': '5-6 hours', 'value': '5_6'},
        {'label': '7-8 hours', 'value': '7_8'},
        {'label': 'More than 8 hours', 'value': '>8'},
      ],
    },
    {
      'id': 'stress_level',
      'question': 'How would you describe your stress level?',
      'options': [
        {'label': 'Very low - relaxed most of the time', 'value': 'low'},
        {'label': 'Moderate - occasional stress', 'value': 'moderate'},
        {'label': 'High - frequently stressed', 'value': 'high'},
        {'label': 'Very high - chronic stress', 'value': 'very_high'},
      ],
    },
    {
      'id': 'diet',
      'question': 'Which best describes your diet?',
      'options': [
        {'label': 'Balanced with all food groups', 'value': 'balanced'},
        {'label': 'Vegetarian or pescatarian', 'value': 'vegetarian'},
        {'label': 'Vegan', 'value': 'vegan'},
        {'label': 'High protein, low carb', 'value': 'high_protein'},
        {'label': 'Irregular eating patterns', 'value': 'irregular'},
      ],
    },
    {
      'id': 'water_intake',
      'question': 'How much water do you drink daily?',
      'options': [
        {'label': 'Less than 2 glasses', 'value': '<2'},
        {'label': '3-5 glasses', 'value': '3_5'},
        {'label': '6-8 glasses', 'value': '6_8'},
        {'label': 'More than 8 glasses', 'value': '>8'},
      ],
    },
    {
      'id': 'exercise',
      'question': 'How often do you exercise?',
      'options': [
        {'label': 'Rarely or never', 'value': 'rarely'},
        {'label': '1-2 times per week', 'value': '1_2'},
        {'label': '3-4 times per week', 'value': '3_4'},
        {'label': '5+ times per week', 'value': '5_plus'},
      ],
    },
    {
      'id': 'sun_exposure',
      'question': 'How much sun exposure do you get daily?',
      'options': [
        {'label': 'Minimal - mostly indoors', 'value': 'minimal'},
        {'label': 'Moderate - 15-30 minutes', 'value': 'moderate'},
        {'label': 'Frequent - 1-2 hours', 'value': 'frequent'},
        {'label': 'Extended - 2+ hours', 'value': 'extended'},
      ],
    },
  ];

  static const List<Map<String, String>> nationalities = [
    {'code': 'US', 'name': 'American'},
    {'code': 'GB', 'name': 'British'},
    {'code': 'CA', 'name': 'Canadian'},
    {'code': 'AU', 'name': 'Australian'},
    {'code': 'FR', 'name': 'French'},
    {'code': 'DE', 'name': 'German'},
    {'code': 'IT', 'name': 'Italian'},
    {'code': 'ES', 'name': 'Spanish'},
    {'code': 'PT', 'name': 'Portuguese'},
    {'code': 'NL', 'name': 'Dutch'},
    {'code': 'SE', 'name': 'Swedish'},
    {'code': 'NO', 'name': 'Norwegian'},
    {'code': 'DK', 'name': 'Danish'},
    {'code': 'FI', 'name': 'Finnish'},
    {'code': 'CH', 'name': 'Swiss'},
    {'code': 'AT', 'name': 'Austrian'},
    {'code': 'BE', 'name': 'Belgian'},
    {'code': 'IE', 'name': 'Irish'},
    {'code': 'JP', 'name': 'Japanese'},
    {'code': 'KR', 'name': 'South Korean'},
    {'code': 'CN', 'name': 'Chinese'},
    {'code': 'IN', 'name': 'Indian'},
    {'code': 'AE', 'name': 'Emirati'},
    {'code': 'SA', 'name': 'Saudi'},
    {'code': 'QA', 'name': 'Qatari'},
    {'code': 'KW', 'name': 'Kuwaiti'},
    {'code': 'BH', 'name': 'Bahraini'},
    {'code': 'OM', 'name': 'Omani'},
    {'code': 'EG', 'name': 'Egyptian'},
    {'code': 'MA', 'name': 'Moroccan'},
    {'code': 'TN', 'name': 'Tunisian'},
    {'code': 'DZ', 'name': 'Algerian'},
    {'code': 'LB', 'name': 'Lebanese'},
    {'code': 'JO', 'name': 'Jordanian'},
    {'code': 'SY', 'name': 'Syrian'},
    {'code': 'IQ', 'name': 'Iraqi'},
    {'code': 'TR', 'name': 'Turkish'},
    {'code': 'IR', 'name': 'Iranian'},
    {'code': 'PK', 'name': 'Pakistani'},
    {'code': 'BD', 'name': 'Bangladeshi'},
    {'code': 'PH', 'name': 'Filipino'},
    {'code': 'TH', 'name': 'Thai'},
    {'code': 'VN', 'name': 'Vietnamese'},
    {'code': 'MY', 'name': 'Malaysian'},
    {'code': 'SG', 'name': 'Singaporean'},
    {'code': 'ID', 'name': 'Indonesian'},
    {'code': 'BR', 'name': 'Brazilian'},
    {'code': 'MX', 'name': 'Mexican'},
    {'code': 'AR', 'name': 'Argentinian'},
    {'code': 'CO', 'name': 'Colombian'},
    {'code': 'CL', 'name': 'Chilean'},
    {'code': 'ZA', 'name': 'South African'},
    {'code': 'NG', 'name': 'Nigerian'},
    {'code': 'KE', 'name': 'Kenyan'},
    {'code': 'GH', 'name': 'Ghanaian'},
    {'code': 'RU', 'name': 'Russian'},
    {'code': 'UA', 'name': 'Ukrainian'},
    {'code': 'PL', 'name': 'Polish'},
    {'code': 'CZ', 'name': 'Czech'},
    {'code': 'HU', 'name': 'Hungarian'},
    {'code': 'RO', 'name': 'Romanian'},
    {'code': 'GR', 'name': 'Greek'},
    {'code': 'IL', 'name': 'Israeli'},
  ];

  static const List<Map<String, String>> climates = [
    {'code': 'tropical', 'name': 'Tropical - Hot and humid year-round'},
    {'code': 'dry', 'name': 'Dry - Hot with low humidity'},
    {'code': 'temperate', 'name': 'Temperate - Moderate seasons'},
    {'code': 'continental', 'name': 'Continental - Cold winters, warm summers'},
    {'code': 'polar', 'name': 'Polar - Cold year-round'},
    {'code': 'mediterranean', 'name': 'Mediterranean - Warm, dry summers, mild winters'},
    {'code': 'mountain', 'name': 'Mountain - Cool, variable weather'},
    {'code': 'coastal', 'name': 'Coastal - Humid, mild temperatures'},
  ];

  static const List<Map<String, dynamic>> subscriptionPlans = [
    {
      'id': 'free',
      'name': 'Free',
      'price': 0.0,
      'currency': 'USD',
      'period': 'month',
      'features': [
        'Basic skin assessment',
        'Daily routine suggestions',
        'Community access',
        '5 AI Coach messages/month',
      ],
    },
    {
      'id': 'plus',
      'name': 'Plus',
      'price': 9.99,
      'currency': 'USD',
      'period': 'month',
      'features': [
        'Everything in Free',
        'Full AI Coach access',
        'Detailed progress tracking',
        'Product compatibility checker',
        'Ingredient analysis',
        'Priority support',
      ],
    },
    {
      'id': 'premium',
      'name': 'Premium',
      'price': 19.99,
      'currency': 'USD',
      'period': 'month',
      'features': [
        'Everything in Plus',
        'Personalized beauty intelligence report',
        'Virtual consultations',
        'Advanced analytics',
        'Exclusive community groups',
        'Early access to new features',
        'Premium support 24/7',
      ],
    },
  ];

  static const String premiumPlanId = 'premium';
  static const String plusPlanId = 'plus';
  static const String freePlanId = 'free';
}
