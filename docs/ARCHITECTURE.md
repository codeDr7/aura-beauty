# Aura - Beauty Intelligence Platform: Architecture Document

---

## 1. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CLIENT LAYER                                      │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────┐        │
│  │                   Flutter Mobile App (Dart)                      │        │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │        │
│  │  │ Screens  │ │ Widgets  │ │Providers │ │ Routers          │  │        │
│  │  │ (UI)     │ │ (Common) │ │(Riverpod)│ │ (GoRouter)       │  │        │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────────┬─────────┘  │        │
│  └───────┼────────────┼────────────┼──────────────────┼────────────┘        │
│          │            │            │                  │                      │
│  ┌───────┼────────────┼────────────┼──────────────────┼────────────┐        │
│  │       │            │            │                  │            │        │
│  │  ┌────▼────────────▼────────────▼──────────────────▼─────────┐  │        │
│  │  │                   Domain Layer                              │  │        │
│  │  │  ┌──────────┐  ┌──────────────┐  ┌─────────────────────┐  │  │        │
│  │  │  │Entities  │  │ Repositories │  │ Use Cases           │  │  │        │
│  │  │  │(Models)  │  │ (Abstract)   │  │ (Business Logic)    │  │  │        │
│  │  │  └──────────┘  └──────────────┘  └─────────────────────┘  │  │        │
│  │  └──────────────────────────┬─────────────────────────────────┘  │        │
│  └─────────────────────────────┼───────────────────────────────────┘        │
│                                │                                            │
│  ┌─────────────────────────────┼───────────────────────────────────┐        │
│  │  │                   Data Layer                                  │        │
│  │  │  ┌──────────────┐  ┌────────────────┐  ┌──────────────────┐ │        │
│  │  │  │ DataSources  │  │ Repositories   │  │ DTOs / Models    │ │        │
│  │  │  │ (Remote/Local)│  │ (Implementations)│  │ (JSON Serialization)│ │        │
│  │  │  └──────┬───────┘  └────────────────┘  └──────────────────┘ │        │
│  │  └─────────┼────────────────────────────────────────────────────┘        │
│              │                                                              │
│              │  HTTPS / REST                                                │
└──────────────┼──────────────────────────────────────────────────────────────┘
               │
┌──────────────▼──────────────────────────────────────────────────────────────┐
│                         SERVER LAYER (Frappe/ERPNext)                        │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────┐        │
│  │                   Frappe Web Framework                           │        │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │        │
│  │  │ API Layer│ │ Hooks    │ │ Scheduler│ │ Permissions      │  │        │
│  │  │ (REST)   │ │ (Events) │ │ (Daily/  │ │ (Role-Based)     │  │        │
│  │  │          │ │          │ │ Weekly)  │ │                  │  │        │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────────┬─────────┘  │        │
│  │       │            │            │                  │            │        │
│  │  ┌────▼────────────▼────────────▼──────────────────▼─────────┐  │        │
│  │  │                   Aura App (Doctypes)                       │  │        │
│  │  │  ┌──────────────┐  ┌──────────────┐  ┌────────────────┐  │  │        │
│  │  │  │ User Profile │  │ Assessments  │  │ Products       │  │  │        │
│  │  │  │ Routines     │  │ Community    │  │ Subscriptions  │  │  │        │
│  │  │  │ AI Coach     │  │ Progress     │  │ Recommendations│  │  │        │
│  │  │  └──────────────┘  └──────────────┘  └────────────────┘  │  │        │
│  │  └──────────────────────────┬─────────────────────────────────┘  │        │
│  └─────────────────────────────┼────────────────────────────────────┘        │
│                                │                                            │
│  ┌─────────────────────────────┼───────────────────────────────────┐        │
│  │                    MariaDB / Redis                               │        │
│  │  ┌─────────────────────┐  ┌──────────────────────────────┐    │        │
│  │  │      MariaDB        │  │         Redis                │    │        │
│  │  │  (Primary Storage)  │  │  (Cache / Session / Queue)   │    │        │
│  │  └─────────────────────┘  └──────────────────────────────┘    │        │
│  └────────────────────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Frontend Architecture

### 2.1 Clean Architecture Layers

The Flutter app follows Clean Architecture with three layers:

```
┌──────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                             │
│                                                                   │
│  screens/        widgets/        providers/                       │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                    │
│  │ Auth     │    │ Common   │    │ Auth     │                    │
│  │ Home     │    │ AppBar   │    │ Profile  │                    │
│  │ Onboard  │    │ Cards    │    │ Products │                    │
│  │ Discover │    │ Buttons  │    │ Routines │                    │
│  │ Routine  │    │ Charts   │    │ Assess   │                    │
│  │ Community│    │ Loading  │    │ Progress │                    │
│  │ Profile  │    │ Empty    │    │ Comm     │                    │
│  │ Progress │    │ Error    │    │ AI Coach │                    │
│  │ AI Coach │    └──────────┘    └──────────┘                    │
│  └──────────┘                                                   │
│                                                                   │
│  Riverpod State Management (ProviderScope / ChangeNotifier)      │
└──────────────────────────┬───────────────────────────────────────┘
                           │ depends on
┌──────────────────────────▼───────────────────────────────────────┐
│                      DOMAIN LAYER                                 │
│                                                                   │
│  entities/           repositories/         usecases/              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │ User         │    │ AuthRepo     │    │ LoginUseCase │       │
│  │ Product      │    │ ProductRepo  │    │ GetProds     │       │
│  │ Assessment   │    │ RoutineRepo  │    │ GenerateRtn  │       │
│  │ Routine      │    │ AssessRepo   │    │ SubmitAssess │       │
│  │ Post         │    │ PostRepo     │    │ GetFeed      │       │
│  │ Subscription │    │ SubRepo      │    │ CheckSub     │       │
│  │ Progress     │    │ ProgressRepo │    │ TrackProgress│       │
│  │ AI Message   │    │ CoachRepo    │    │ SendMessage  │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│                                                                   │
│  Pure Dart classes - no framework dependencies                    │
│  Repository interfaces (abstract classes)                         │
└──────────────────────────┬───────────────────────────────────────┘
                           │ implemented by
┌──────────────────────────▼───────────────────────────────────────┐
│                       DATA LAYER                                  │
│                                                                   │
│  datasources/        models/            repositories/             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │ RemoteDS     │    │ UserModel    │    │ AuthRepoImpl │       │
│  │ (Dio/HTTP)   │    │ ProductModel │    │ ProductImpl  │       │
│  │ LocalDS      │    │ AssessModel  │    │ RoutineImpl  │       │
│  │ (SecureStr)  │    │ PostModel    │    │ AssessImpl   │       │
│  │ CacheDS      │    │ RoutineModel │    │ PostImpl     │       │
│  │              │    │ CoachModel   │    │ CoachImpl    │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│                                                                   │
│  Dio HTTP Client, JSON Serialization (json_serializable)          │
│  flutter_secure_storage for tokens, error handling                │
└──────────────────────────────────────────────────────────────────┘
```

### 2.2 Riverpod State Management Pattern

```
┌──────────────────────────────────────────────────────────────────┐
│                 PROVIDER ARCHITECTURE                              │
│                                                                   │
│  Global Providers (app.dart):                                     │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  ProviderScope ─── root provider container                │    │
│  │  ├── goRouterProvider ─── GoRouter instance               │    │
│  │  ├── dioClientProvider ─── Dio HTTP client                 │    │
│  │  ├── authProvider ─── AuthNotifier (StateNotifier)        │    │
│  │  ├── profileProvider ─── ProfileNotifier                   │    │
│  │  ├── themeProvider ─── ThemeMode state                    │    │
│  │  └── localeProvider ─── Locale state                      │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                   │
│  Feature Providers:                                               │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  Product Providers:                                        │    │
│  │  ├── productListProvider ─── AsyncNotifier<List<Product>> │    │
│  │  ├── productDetailProvider ─── Family(id)                 │    │
│  │  └── productSearchProvider ─── StateNotifier              │    │
│  │                                                           │    │
│  │  Assessment Providers:                                     │    │
│  │  ├── skinAssessmentProvider ─── AsyncNotifier             │    │
│  │  ├── hairAssessmentProvider ─── AsyncNotifier             │    │
│  │  └── lifestyleAssessmentProvider ─── AsyncNotifier        │    │
│  │                                                           │    │
│  │  Community Providers:                                      │    │
│  │  ├── feedProvider ─── AsyncNotifier<List<Post>>           │    │
│  │  ├── groupsProvider ─── AsyncNotifier<List<Group>>        │    │
│  │  ├── challengesProvider ─── AsyncNotifier                 │    │
│  │  └── postDetailProvider ─── Family(id)                    │    │
│  │                                                           │    │
│  │  Routine Providers:                                        │    │
│  │  ├── routineProvider ─── AsyncNotifier                    │    │
│  │  └── routineStepProvider ─── StateNotifier                │    │
│  │                                                           │    │
│  │  Progress Providers:                                       │    │
│  │  ├── progressProvider ─── AsyncNotifier                   │    │
│  │  └── chartsProvider ─── AsyncNotifier                     │    │
│  │                                                           │    │
│  │  AI Coach Providers:                                       │    │
│  │  ├── conversationProvider ─── StateNotifier               │    │
│  │  └── coachingResponseProvider ─── FutureProvider          │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                   │
│  Pattern:                                                        │
│  - StateNotifierProvider for mutable state                       │
│  - FutureProvider / AsyncNotifier for async data                 │
│  - Provider for sync computed values                             │
│  - family modifier for parameterized providers                   │
└──────────────────────────────────────────────────────────────────┘
```

### 2.3 GoRouter Navigation Structure

```
┌──────────────────────────────────────────────────────────────────┐
│                     ROUTE TREE (GoRouter)                         │
│                                                                   │
│  /                                                               │
│  ├── /splash ───────────────────── SplashScreen                  │
│  │                                                               │
│  ├── /auth                                                        │
│  │   ├── /auth/login ──────────── LoginScreen                    │
│  │   ├── /auth/register ───────── SignUpScreen                   │
│  │   └── /auth/forgot-password ── ForgotPasswordScreen           │
│  │                                                               │
│  ├── /onboarding                                                  │
│  │   ├── /onboarding/welcome ──── WelcomeScreen                  │
│  │   ├── /onboarding/skin ─────── SkinAssessmentScreen           │
│  │   ├── /onboarding/hair ─────── HairAssessmentScreen           │
│  │   ├── /onboarding/lifestyle ── LifestyleAssessmentScreen      │
│  │   └── /onboarding/goals ────── GoalSelectionScreen            │
│  │                                                               │
│  ├── /app (ShellRoute with BottomNavBar)                          │
│  │   ├── /app/home ────────────── HomeScreen                     │
│  │   ├── /app/discover ────────── DiscoverScreen                 │
│  │   ├── /app/community ───────── CommunityScreen                │
│  │   ├── /app/routine ─────────── RoutineScreen                  │
│  │   └── /app/profile ─────────── ProfileScreen                  │
│  │                                                               │
│  ├── /products                                                    │
│  │   ├── /products ────────────── ProductListScreen              │
│  │   ├── /products/:id ────────── ProductDetailScreen            │
│  │   └── /products/search ─────── ProductSearchScreen            │
│  │                                                               │
│  ├── /assessments                                                 │
│  │   ├── /assessments/skin ────── SkinAssessmentScreen           │
│  │   ├── /assessments/hair ────── HairAssessmentScreen           │
│  │   ├── /assessments/lifestyle ── LifestyleAssessmentScreen     │
│  │   └── /assessments/history ──── AssessmentHistoryScreen       │
│  │                                                               │
│  ├── /community                                                   │
│  │   ├── /community/posts/:id ─── PostDetailScreen               │
│  │   ├── /community/create ────── CreatePostScreen               │
│  │   ├── /community/groups ────── GroupsScreen                   │
│  │   ├── /community/groups/:id ── GroupDetailScreen              │
│  │   ├── /community/challenges ─── ChallengesScreen              │
│  │   └── /community/challenges/:id ── ChallengeDetailScreen      │
│  │                                                               │
│  ├── /routines                                                    │
│  │   ├── /routines ────────────── RoutineListScreen              │
│  │   ├── /routines/:id ────────── RoutineDetailScreen            │
│  │   └── /routines/create ─────── CreateRoutineScreen            │
│  │                                                               │
│  ├── /progress                                                    │
│  │   ├── /progress ────────────── ProgressDashboardScreen        │
│  │   ├── /progress/add ────────── AddProgressEntryScreen         │
│  │   ├── /progress/skin ────────── SkinProgressChartScreen       │
│  │   ├── /progress/hair ────────── HairProgressChartScreen        │
│  │   └── /progress/lifestyle ───── LifestyleProgressScreen        │
│  │                                                               │
│  ├── /ai-coach                                                    │
│  │   └── /ai-coach/chat ───────── AICoachChatScreen              │
│  │                                                               │
│  ├── /subscription                                                │
│  │   ├── /subscription ────────── SubscriptionScreen             │
│  │   └── /subscription/checkout ── CheckoutScreen                │
│  │                                                               │
│  ├── /settings                                                    │
│  │   ├── /settings ────────────── SettingsScreen                 │
│  │   └── /settings/profile ────── EditProfileScreen              │
│  │                                                               │
│  └── /notifications ───────────── NotificationsScreen            │
│                                                                   │
│  Route Guards (redirects):                                        │
│  - Unauthenticated → /auth/login                                  │
│  - Authenticated + no assessment → /onboarding                    │
│  - Deep links → resolved to specific route                        │
└──────────────────────────────────────────────────────────────────┘
```

### 2.4 Widget Tree Hierarchy

```
MaterialApp.router
 └── ProviderScope
      └── GoRouter
           ├── SplashScreen
           │    ├── LogoAnimation
           │    └── LoadingIndicator
           │
           ├── AuthScreen
           │    ├── LoginForm
           │    │    ├── EmailField
           │    │    ├── PasswordField
           │    │    └── LoginButton
           │    ├── RegisterForm
           │    │    ├── NameField
           │    │    ├── EmailField
           │    │    ├── PasswordField
           │    │    └── RegisterButton
           │    └── SocialLoginRow
           │
           ├── OnboardingScreen
           │    ├── OnboardingStepper
           │    ├── SkinAssessmentForm
           │    ├── HairAssessmentForm
           │    ├── LifestyleAssessmentForm
           │    └── GoalSelectionGrid
           │
           ├── MainShell (BottomNavigationBar)
           │    ├── HomeScreen
           │    │    ├── AuraScoreCard
           │    │    ├── QuickActionGrid
           │    │    ├── RecommendationCarousel
           │    │    └── UpcomingRoutineCard
           │    ├── DiscoverScreen
           │    │    ├── SearchBar
           │    │    ├── CategoryFilterChips
           │    │    └── ProductGrid
           │    ├── CommunityScreen
           │    │    ├── FeedTabs (ForYou / Following)
           │    │    ├── PostCard (reusable)
           │    │    └── CreatePostFAB
           │    ├── RoutineScreen
           │    │    ├── RoutineTimeline
           │    │    └── RoutineStepCard
           │    └── ProfileScreen
           │         ├── ProfileHeader
           │         ├── StatsRow
           │         └── SettingsList
           │
           ├── ProductDetailScreen
           │    ├── ProductImageGallery
           │    ├── ProductInfoSection
           │    ├── IngredientList
           │    └── AddToRoutineButton
           │
           ├── PostDetailScreen
           │    ├── PostContent
           │    ├── CommentSection
           │    │    └── CommentTile
           │    └── LikeShareRow
           │
           ├── AICoachChatScreen
           │    ├── ChatBubbleList
           │    │    ├── UserBubble
           │    │    └── CoachBubble
           │    └── MessageInputBar
           │
           └── ProgressDashboardScreen
                ├── ScoreOverviewChart
                ├── TrendLineChart
                └── MilestoneList
```

---

## 3. Backend Architecture

### 3.1 Frappe Framework App Structure

```
backend/aura/
├── __init__.py
├── setup.py                          # Python package setup
├── requirements.txt                  # Python dependencies
├── hooks.py                          # Frappe app hooks
├── patches.txt                       # Patch versions tracking
├── patches/                          # DB migration patches
│
├── aura/                             # Main app package
│   ├── __init__.py
│   │
│   ├── api/                          # REST API endpoints
│   │   ├── __init__.py
│   │   ├── auth.py                   # Authentication APIs
│   │   ├── profile.py               # User profile APIs
│   │   ├── assessments.py           # Assessment APIs
│   │   ├── products.py              # Product intelligence APIs
│   │   ├── recommendations.py       # Recommendation APIs
│   │   ├── routines.py              # Routine management APIs
│   │   ├── community.py             # Community/social APIs
│   │   ├── progress.py              # Progress tracking APIs
│   │   ├── subscriptions.py         # Subscription APIs
│   │   └── ai_coach.py              # AI Coach APIs
│   │
│   ├── doctype/                      # DocType definitions
│   │   ├── beauty_user_profile/      # User profile DocType
│   │   ├── skin_assessment/          # Skin assessment DocType
│   │   ├── hair_assessment/          # Hair assessment DocType
│   │   ├── lifestyle_assessment/     # Lifestyle assessment DocType
│   │   ├── beauty_product/           # Product catalog DocType
│   │   ├── product_ingredient/       # Product ingredients child
│   │   ├── product_concern/          # Product-concern mapping child
│   │   ├── concern_tag/              # Concern taxonomy DocType
│   │   ├── assessment_goal/          # Goals child table
│   │   ├── recommendation_result/    # Recommendation results DocType
│   │   ├── routine_template/         # Routine templates DocType
│   │   ├── user_routine/             # User routines DocType
│   │   ├── community_post/           # Community posts DocType
│   │   ├── community_comment/        # Post comments DocType
│   │   ├── community_group/          # Interest groups DocType
│   │   ├── challenge/                # Community challenges DocType
│   │   ├── progress_entry/           # Progress tracking DocType
│   │   ├── subscription_plan/        # Subscription plans DocType
│   │   ├── user_subscription/        # User subscriptions DocType
│   │   └── ai_conversation/          # AI chat history DocType
│   │
│   ├── tasks/                        # Scheduled tasks
│   │   ├── __init__.py
│   │   ├── daily.py                  # Daily batch tasks
│   │   ├── weekly.py                 # Weekly batch tasks
│   │   └── monthly.py                # Monthly batch tasks
│   │
│   ├── recommendation_engine/        # Recommendation logic
│   │   ├── __init__.py
│   │   ├── scorer.py                 # Scoring algorithm
│   │   ├── matcher.py                # Product-user matching
│   │   └── routine_generator.py      # Routine generation
│   │
│   └── utils/                        # Utility modules
│       ├── __init__.py
│       ├── validators.py             # Input validators
│       └── helpers.py                # Helper functions
│
└── fixtures/                         # Default data fixtures
```

### 3.2 DocType Relationships and ERD

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      ENTITY RELATIONSHIP DIAGRAM                        │
│                                                                         │
│  ┌──────────────────┐      ┌───────────────────┐                       │
│  │      User        │◄─────│ BeautyUserProfile  │                       │
│  │  (Frappe Auth)   │  1:1 │  user (Link)       │                       │
│  └──────────────────┘      └────────┬──────────┘                       │
│                                     │                                    │
│             ┌───────────────────────┼───────────────────────┐           │
│             │                       │                       │           │
│             ▼                       ▼                       ▼           │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐ │
│  │  SkinAssessment    │  │  HairAssessment    │  │  LifestyleAssess   │ │
│  │  user → Profile    │  │  user → Profile    │  │  user → Profile    │ │
│  │  main_goals → Goal │  │  main_goals → Goal │  │                    │ │
│  └─────────┬──────────┘  └─────────┬──────────┘  └────────────────────┘ │
│            │                       │                                     │
│            └───────────┬───────────┘                                     │
│                        ▼                                                 │
│             ┌────────────────────┐                                       │
│             │ AssessmentGoal    │  (Child Table / Table MultiSelect)    │
│             │ parent → parenttype│                                       │
│             └────────────────────┘                                       │
│                                                                         │
│  ┌──────────────────┐        ┌──────────────────┐                       │
│  │  BeautyProduct   │        │  ConcernTag      │                       │
│  │  concerns → PC   │────────│  (Taxonomy)      │                       │
│  │  ingredients → PI │       └──────────────────┘                       │
│  │  skin_types → AG │                                                   │
│  │  hair_types → AG  │        ┌──────────────────┐                       │
│  └────────┬─────────┘        │ ProductConcern   │ (Child Table)         │
│           │                  │ parent → Product  │                       │
│           │                  └──────────────────┘                       │
│           │                                                             │
│           │                  ┌──────────────────┐                       │
│           └──────────────────│ ProductIngredient│ (Child Table)         │
│                              │ parent → Product  │                       │
│                              └──────────────────┘                       │
│                                                                         │
│  ┌──────────────────┐      ┌───────────────────┐                       │
│  │ RoutineTemplate  │      │  UserRoutine      │                       │
│  │  (Predefined)    │      │  user → Profile   │                       │
│  └──────────────────┘      └───────────────────┘                       │
│                                                                         │
│  ┌──────────────────┐      ┌───────────────────┐                       │
│  │ CommunityPost    │◄─────│  CommunityComment │                       │
│  │  user → Profile  │  1:N │  post → Post      │                       │
│  │  group → Group   │      │  user → Profile   │                       │
│  └────────┬─────────┘      └───────────────────┘                       │
│           │                                                             │
│           │              ┌───────────────────┐                          │
│           └──────────────│  CommunityGroup   │                          │
│                          │  (created_by)     │                          │
│                          └───────────────────┘                          │
│                                                                         │
│  ┌──────────────────┐      ┌───────────────────┐                       │
│  │ Challenge        │      │  ProgressEntry    │                       │
│  │  created_by      │      │  user → Profile   │                       │
│  └──────────────────┘      └───────────────────┘                       │
│                                                                         │
│  ┌──────────────────┐      ┌───────────────────┐                       │
│  │ Recommendation   │      │  AIConversation   │                       │
│  │  Result          │      │  user → Profile   │                       │
│  │  user → Profile  │      └───────────────────┘                       │
│  └──────────────────┘                                                   │
│                                                                         │
│  ┌──────────────────┐      ┌───────────────────┐                       │
│  │ SubscriptionPlan │      │  UserSubscription  │                       │
│  │  (Static)        │◄─────│  user → Profile   │                       │
│  └──────────────────┘  1:N │  plan → SubPlan    │                       │
│                            └───────────────────┘                       │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.3 API Layer Organization

All APIs are exposed via Frappe's REST API framework at `/api/method/aura.api.*`:

```
API Endpoint Structure:

/api/method/aura.api.auth.login                     POST
/api/method/aura.api.auth.register                   POST
/api/method/aura.api.auth.logout                    POST
/api/method/aura.api.auth.reset_password             POST
/api/method/aura.api.profile.get_profile             GET
/api/method/aura.api.profile.update_profile          PUT
/api/method/aura.api.assessments.submit_skin         POST
/api/method/aura.api.assessments.submit_hair         POST
/api/method/aura.api.assessments.submit_lifestyle    POST
/api/method/aura.api.assessments.get_history         GET
/api/method/aura.api.products.list                   GET
/api/method/aura.api.products.get                    GET
/api/method/aura.api.products.search                 GET
/api/method/aura.api.recommendations.get             GET
/api/method/aura.api.recommendations.regenerate      POST
/api/method/aura.api.routines.get_routine            GET
/api/method/aura.api.routines.create                 POST
/api/method/aura.api.routines.update_step            PUT
/api/method/aura.api.community.create_post           POST
/api/method/aura.api.community.get_feed              GET
/api/method/aura.api.community.add_comment           POST
/api/method/aura.api.community.like_post             POST
/api/method/aura.api.community.get_groups            GET
/api/method/aura.api.community.get_challenges        GET
/api/method/aura.api.progress.add_entry              POST
/api/method/aura.api.progress.get_history            GET
/api/method/aura.api.progress.get_charts             GET
/api/method/aura.api.subscriptions.get_plans         GET
/api/method/aura.api.subscriptions.subscribe         POST
/api/method/aura.api.subscriptions.cancel            POST
/api/method/aura.api.subscriptions.get_status        GET
/api/method/aura.api.ai_coach.send_message           POST
/api/method/aura.api.ai_coach.get_conversation       GET
/api/method/aura.api.ai_coach.clear_chat             DELETE
```

### 3.4 Role-Based Access Control

| Role | Permissions |
|---|---|
| **System Manager** | Full CRUD on all DocTypes |
| **Item Manager** | Create/Read/Write on Beauty Product, Ingredients |
| **All (Authenticated User)** | Read own profile, Create assessments, Create posts/comments, Manage own routines, Read products, Read community content |
| **Unauthenticated** | Login only |

Detailed permission matrix from `hooks.py`:

| DocType | System Manager | Item Manager | All (User) |
|---|---|---|---|
| Beauty User Profile | CRUD | - | R, W (own) |
| Skin Assessment | CRUD | - | R, C (own) |
| Hair Assessment | CRUD | - | R, C (own) |
| Lifestyle Assessment | CRUD | - | R, C (own) |
| Beauty Product | CRUD | CRUD | R |
| User Routine | CRUD | - | CR, U (own) |
| Community Post | CRUD | - | CRUD (own) |
| Community Comment | CRUD | - | CRUD (own) |
| Community Group | CRUD | - | R |
| AI Conversation | CRUD | - | R, C (own) |
| Recommendation Result | CRUD | - | R |
| Subscription Plan | CRUD | - | R |
| User Subscription | CRUD | - | R |

---

## 4. Data Flow

### 4.1 Authentication Flow

```
┌──────────┐         ┌──────────┐         ┌──────────┐         ┌──────────┐
│  Flutter  │         │  Frappe  │         │  MariaDB │         │  Redis   │
│   App     │         │   API    │         │          │         │ (Session)│
└─────┬─────┘         └────┬─────┘         └──────────┘         └──────────┘
      │                    │                                         │
      │   POST /login      │                                         │
      │   {email, pass}    │                                         │
      │───────────────────►│                                         │
      │                    │   Validate credentials                  │
      │                    │──────────────►                           │
      │                    │◄──────────────                           │
      │                    │                                         │
      │                    │   Generate API Key/Secret                │
      │                    │─────────────────────────────►           │
      │                    │◄─────────────────────────────           │
      │                    │                                         │
      │   {api_key,        │                                         │
      │    api_secret,     │                                         │
      │    user,           │                                         │
      │    profile_exists} │                                         │
      │◄───────────────────│                                         │
      │                    │                                         │
      │  Store in          │                                         │
      │  SecureStorage     │                                         │
      │────────────────────                                        │
      │                    │                                         │
      │   Redirect:                                                  │
      │   Has Profile?                                              │
      │   ├── Yes → /app/home                                       │
      │   └── No  → /onboarding/welcome                             │
```

### 4.2 Assessment Flow

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Flutter  │         │  Frappe  │         │ MariaDB  │
│   App     │         │   API    │         │          │
└─────┬─────┘         └────┬─────┘         └──────────┘
      │                    │                    │
      │  POST /assessment  │                    │
      │  {type: "skin",   │                    │
      │   answers: {...}}  │                    │
      │───────────────────►│                    │
      │                    │  Validate payload  │
      │                    │                    │
      │                    │  Create Skin       │
      │                    │  Assessment doc    │
      │                    │──────────────────► │
      │                    │◄────────────────── │
      │                    │                    │
      │                    │  Update Profile    │
      │                    │  skin_type,        │
      │                    │  last_assessment   │
      │                    │──────────────────► │
      │                    │◄────────────────── │
      │                    │                    │
      │                    │  Trigger            │
      │                    │  recommendation     │
      │                    │  engine            │
      │                    │  (async)           │
      │                    │                    │
      │  {success: true,   │                    │
      │   score: 78,       │                    │
      │   goals: [...]}    │                    │
      │◄───────────────────│                    │
      │                    │                    │
```

### 4.3 Recommendation Engine Flow

```
┌──────────┐    ┌──────────────┐    ┌──────────┐    ┌──────────────┐
│  Flutter  │    │  Frappe API  │    │  Engine  │    │   MariaDB    │
└─────┬─────┘    └──────┬───────┘    └────┬─────┘    └──────┬───────┘
      │                 │                 │                 │
      │ GET /recommend  │                 │                 │
      │────────────────►│                 │                 │
      │                 │ Load user       │                 │
      │                 │ profile +       │                 │
      │                 │ assessments     │                 │
      │                 │────────────────►│                 │
      │                 │                 │ Fetch products  │
      │                 │                 │────────────────►│
      │                 │                 │◄────────────────│
      │                 │                 │                 │
      │                 │                 │ Score each      │
      │                 │                 │ product:        │
      │                 │                 │ 1. Skin match   │
      │                 │                 │ 2. Concern      │
      │                 │                 │ 3. Goal align   │
      │                 │                 │ 4. Ingredient   │
      │                 │                 │ 5. AI weight    │
      │                 │                 │                 │
      │                 │                 │ Sort by score   │
      │                 │                 │ Return top N    │
      │                 │◄────────────────│                 │
      │                 │                 │                 │
      │                 │ Cache result    │                 │
      │                 │ in Redis        │                 │
      │◄────────────────│                 │                 │
      │                 │                 │                 │
```

### 4.4 Community Interaction Flow

```
┌──────────┐    ┌──────────────┐    ┌──────────┐    ┌──────────────┐
│  User A   │    │  Flutter App │    │  Frappe  │    │  User B      │
│  (Device) │    │  (Feed)      │    │  API     │    │  (Device)    │
└─────┬─────┘    └──────┬───────┘    └────┬─────┘    └──────┬───────┘
      │                 │                 │                 │
      │ Post content    │                 │                 │
      │────────────────►│                 │                 │
      │                 │ POST /post      │                 │
      │                 │────────────────►│                 │
      │                 │                 │ Save + Notify   │
      │                 │                 │                 │
      │                 │◄──── new post ──│                 │
      │◄──── success ───│                 │                 │
      │                 │                 │                 │
      │                 │                 │  Push notif     │
      │                 │                 │────────────────►│
      │                 │                 │                 │
      │                 │                 │  GET /feed      │
      │                 │◄────────────────│◄────────────────│
      │                 │                 │                 │
      │                 │ Post appears    │                 │
      │                 │ in feed         │                 │
      │                 │                 │                 │
      │  Like/Comment   │                 │                 │
      │────────────────►│                 │                 │
      │                 │ POST /like      │                 │
      │                 │────────────────►│                 │
      │                 │                 │ Update count    │
      │                 │◄──── success ───│                 │
```

---

## 5. Key Design Decisions

### 5.1 Frappe + ERPNext as Backend

**Decision**: Use ERPNext (Frappe) as the backend framework instead of a custom Python/Django backend.

**Rationale**:
- Built-in user authentication and permission system
- Admin dashboard (Desk) automatically generated from DocTypes
- Role-based access control with granular permission levels
- Built-in REST API for all DocTypes
- Background job scheduling via hooks
- Database migration system (patches)
- Multi-tenancy support built-in
- Reduced development time for CRUD operations by ~60%

**Trade-off**: Heavier than a micro-framework, but eliminates need to build admin interfaces, auth, and permissions from scratch.

### 5.2 Clean Architecture in Flutter

**Decision**: Implement Clean Architecture with Riverpod for state management.

**Rationale**:
- Separation of concerns: UI, business logic, and data access are decoupled
- Testability: domain layer is pure Dart without framework dependencies
- Scalability: new features can be added without modifying existing layers
- Riverpod: compile-time safety, no `BuildContext` dependency for providers, better testability than Provider
- GoRouter: declarative routing with deep linking support, redirect guards for auth flow

### 5.3 Table MultiSelect for Polymorphic Relationships

**Decision**: Use Frappe's Table MultiSelect field type for many-to-many relationships (e.g., product concerns, assessment goals).

**Rationale**: Avoids need for separate junction tables while maintaining proper relational integrity in MariaDB.

### 5.4 Async Recommendation Generation

**Decision**: Generate recommendations asynchronously via scheduler events rather than real-time.

**Rationale**:
- Recommendation scoring is computationally expensive
- Results are cached in Redis for fast retrieval
- Daily regeneration ensures fresh data without blocking API responses
- Falls back to cached results if regeneration fails

### 5.5 Role-Based Visibility for Community Content

**Decision**: All users can read community content but only document owners can delete.

**Rationale**: Balances free speech with moderation capabilities (System Managers have full delete).

---

## 6. Scalability Considerations

### 6.1 Database Scaling

- Frappe's MariaDB can be vertically scaled or migrated to a clustered setup
- Indexes on frequently queried fields (`user`, `product_name`, `category`, `created_date`)
- Partitioning consideration for `Progress Entry` and `AI Conversation` tables (time-based)

### 6.2 App Server Scaling

- Frappe supports horizontal scaling with multiple workers behind a load balancer
- Session state stored in Redis (stateless app servers)
- Background tasks (recommendation, notifications) can be offloaded to dedicated worker queues

### 6.3 Caching Strategy

| Cache Target | Cache Key | TTL | Strategy |
|---|---|---|---|
| Product Catalog | `products:all` | 1 hour | Cache-aside |
| Product Detail | `product:{id}` | 1 hour | Cache-aside |
| User Recommendations | `recs:{user_id}` | 24 hours | Write-behind |
| Assessment Results | `assess:{user_id}:{type}` | 24 hours | Cache-aside |
| Community Feed | `feed:for_you:{user_id}` | 15 min | Refresh-ahead |
| Product Search | `search:{query}` | 30 min | Cache-aside |
| API Rate Limit | `ratelimit:{ip}:{endpoint}` | 1 min | Sliding window |

### 6.4 Flutter Performance

- Lazy loading for community feed (paginated, 20 items per page)
- Cached network images with disk caching
- Shimmer loading placeholders during API calls
- Riverpod `autoDispose` for screens not in memory
- Preloading assessment data for offline-first experience
- Background fetch for recommendations

### 6.5 Future Horizontal Scaling

- Separate Redis cluster for caching vs. session management
- Read replicas for MariaDB (separate read/write connections)
- CDN for product images and static assets
- WebSocket-based real-time updates for community interactions (Firebase)
- Micro-frontend approach for the Frappe Desk admin panel

### 6.6 Monitoring

- Frappe Error Snapshot for server-side exceptions
- Sentry integration for Flutter crashes
- Frappe Site Analysis for database query profiling
- Custom Prometheus metrics for recommendation engine performance
