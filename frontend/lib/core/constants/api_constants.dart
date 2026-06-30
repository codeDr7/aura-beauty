class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://102.213.180.186:8000',
  );

  static const String apiMethod = '/api/method';
  static const String apiResource = '/api/resource';

  // Auth endpoints
  static const String login = '$apiMethod/login';
  static const String register = '$apiMethod/aura.api.auth.register';
  static const String googleLogin = '$apiMethod/aura.api.auth.google_login';
  static const String logout = '$apiMethod/logout';
  static const String generateKeys = '$apiMethod/aura.api.auth.generate_api_keys';
  static const String refreshToken = '$apiMethod/login';

  // Profile
  static const String getProfile = '$apiMethod/aura.api.profile.get_profile';
  static const String updateProfile = '$apiMethod/aura.api.profile.update_profile';

  // Assessments
  static const String submitAssessment = '$apiMethod/aura.api.assessments.submit_assessment';
  static const String getAssessmentHistory = '$apiMethod/aura.api.assessments.get_assessment_history';

  // Products
  static const String getProducts = '$apiMethod/aura.api.products.get_products';
  static const String getProduct = '$apiMethod/aura.api.products.get_product';
  static const String searchProducts = '$apiMethod/aura.api.products.search_products';
  static const String setPriceAlert = '$apiMethod/aura.api.products.set_price_alert';

  // Recommendations
  static const String getRecommendations = '$apiMethod/aura.api.recommendations.get_recommendations';

  // Marketplace
  static const String placeOrder = '$apiMethod/aura.api.marketplace.place_order';
  static const String partnerRegister = '$apiMethod/aura.api.marketplace.partner_register';
  static const String partnerGetOrders = '$apiMethod/aura.api.marketplace.partner_get_orders';
  static const String partnerUpdateOrderStatus = '$apiMethod/aura.api.marketplace.partner_update_order_status';

  // Subscriptions
  static const String getPlans = '$apiMethod/aura.api.subscriptions.get_plans';
  static const String upgradePlan = '$apiMethod/aura.api.subscriptions.upgrade_plan';
  static const String cancelSubscription = '$apiMethod/aura.api.subscriptions.cancel_subscription';

  // Community
  static const String createPost = '$apiMethod/aura.api.community.create_post';
  static const String getFeed = '$apiMethod/aura.api.community.get_feed';
  static const String addComment = '$apiMethod/aura.api.community.add_comment';
  static const String toggleLike = '$apiMethod/aura.api.community.toggle_like';
  static const String getGroups = '$apiMethod/aura.api.community.get_groups';

  // Routines
  static const String getRoutines = '$apiMethod/aura.api.routines.get_routines';
  static const String startRoutine = '$apiMethod/aura.api.routines.start_routine';
  static const String completeStep = '$apiMethod/aura.api.routines.complete_step';
  static const String getTemplates = '$apiMethod/aura.api.routines.get_templates';

  // Progress
  static const String getProgress = '$apiMethod/aura.api.progress.get_progress';
  static const String logProgress = '$apiMethod/aura.api.progress.log_progress';

  // Badges
  static const String getMyBadges = '$apiMethod/aura.api.badges.get_my_badges';
  static const String getAllBadges = '$apiMethod/aura.api.badges.get_all_badges';

  // Ingredients
  static const String getIngredients = '$apiMethod/aura.api.ingredients.get_ingredients';
  static const String getIngredientConflicts = '$apiMethod/aura.api.ingredients.get_conflicts';

  // Need Analyzer
  static const String analyzeNeeds = '$apiMethod/aura.api.need_analyzer.analyze_needs';

  // AI Coach
  static const String aiCoachChat = '$apiMethod/aura.api.ai_coach.chat';
  static const String aiCoachHistory = '$apiMethod/aura.api.ai_coach.get_history';

  // REST resources
  static const String concernTag = '$apiResource/Concern Tag';
  static const String subscriptionPlan = '$apiResource/Aura Subscription Plan';
  static const String routineTemplate = '$apiResource/Routine Template';
  static const String achievementBadge = '$apiResource/Achievement Badge';
  static const String beautyProduct = '$apiResource/Beauty Product';
  static const String communityPost = '$apiResource/Community Post';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Storage keys
  static const String storageKeyAccessToken = 'access_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyUserId = 'user_id';
  static const String storageKeyUserData = 'user_data';
  static const String storageKeyOnboardingComplete = 'onboarding_complete';
  static const String storageKeyThemeMode = 'theme_mode';
  static const String storageKeyLocale = 'locale';
  static const String storageKeyNotificationsEnabled = 'notifications_enabled';
  static const String storageKeyAssessmentData = 'assessment_data';
  static const String storageKeyApiKey = 'api_key';
  static const String storageKeyApiSecret = 'api_secret';
  static const String storageKeyDeviceId = 'device_id';

  static const String appVersion = '1.0.0';

  // Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAcceptLanguage = 'Accept-Language';
  static const String headerXDeviceId = 'X-Device-Id';
  static const String headerXAppVersion = 'X-App-Version';
  static const String headerXApiKey = 'X-API-Key';
  static const String headerXApiSecret = 'X-API-Secret';
  static const String headerHost = 'Host';

  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';
  static const String hostHeader = 'aura-beauty.erpnext.local';
}
