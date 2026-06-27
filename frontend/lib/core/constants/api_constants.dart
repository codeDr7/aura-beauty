class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.aurabeauty.app/v1',
  );

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String deleteAccount = '/user/account';
  static const String changePassword = '/user/password';

  // Onboarding / Assessment
  static const String saveSkinAssessment = '/assessment/skin';
  static const String saveHairAssessment = '/assessment/hair';
  static const String saveLifestyleAssessment = '/assessment/lifestyle';
  static const String getAssessmentResults = '/assessment/results';
  static const String getAssessmentById = '/assessment';

  // Routines
  static const String routines = '/routines';
  static const String routineById = '/routines';
  static const String completeRoutineStep = '/routines/complete';

  // Products
  static const String products = '/products';
  static const String productById = '/products';
  static const String productSearch = '/products/search';
  static const String productCategories = '/products/categories';
  static const String productRecommendations = '/products/recommendations';
  static const String productIngredients = '/products/ingredients';

  // Community
  static const String posts = '/community/posts';
  static const String postById = '/community/posts';
  static const String postLikes = '/community/posts/like';
  static const String postComments = '/community/posts/comments';

  static const String groups = '/community/groups';
  static const String groupById = '/community/groups';
  static const String joinGroup = '/community/groups/join';
  static const String leaveGroup = '/community/groups/leave';

  static const String challenges = '/community/challenges';
  static const String challengeById = '/community/challenges';
  static const String joinChallenge = '/community/challenges/join';
  static const String challengeProgress = '/community/challenges/progress';

  // AI Coach
  static const String aiCoachChat = '/ai-coach/chat';
  static const String aiCoachHistory = '/ai-coach/history';
  static const String aiCoachAnalyze = '/ai-coach/analyze';
  static const String aiCoachRecommend = '/ai-coach/recommend';

  // Progress & Statistics
  static const String progressTimeline = '/progress/timeline';
  static const String progressStats = '/progress/statistics';
  static const String progressCharts = '/progress/charts';
  static const String progressSkinScore = '/progress/skin-score';
  static const String progressHairScore = '/progress/hair-score';

  // Subscription
  static const String subscriptionPlans = '/subscription/plans';
  static const String currentSubscription = '/subscription/current';
  static const String createCheckoutSession = '/subscription/checkout';
  static const String cancelSubscription = '/subscription/cancel';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';
  static const String registerFcmToken = '/notifications/fcm-token';
  static const String notificationSettings = '/notifications/settings';

  // Upload
  static const String uploadImage = '/upload/image';
  static const String uploadFile = '/upload/file';

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

  // Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAcceptLanguage = 'Accept-Language';
  static const String headerXDeviceId = 'X-Device-Id';
  static const String headerXAppVersion = 'X-App-Version';

  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';
}
