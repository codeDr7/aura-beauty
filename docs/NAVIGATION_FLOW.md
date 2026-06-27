# Aura - Beauty Intelligence Platform: Navigation Flow

---

## 1. App Flow Diagram (ASCII Art)

```
┌──────────────────────────────────────────────────────────────────────┐
│                        AURA APP FLOW                                  │
│                                                                       │
│  ┌─────────┐                                                         │
│  │ SPLASH  │                                                         │
│  │ SCREEN  │                                                         │
│  └────┬────┘                                                         │
│       │                                                               │
│       │  Check Auth Token                                              │
│       │                                                               │
│       ├── No Token ──────────────────────────┐                       │
│       │                                      ▼                       │
│       │                              ┌──────────────┐                │
│       │                              │  AUTH FLOW   │                │
│       │                              │              │                │
│       │                              │ /auth/login  │                │
│       │                              │ /auth/       │                │
│       │                              │ register     │                │
│       │                              │ /auth/       │                │
│       │                              │ forgot-pwd   │                │
│       │                              └──────┬───────┘                │
│       │                                     │                        │
│       │                                     │ Login Success          │
│       └── Has Token ────────┐               │                        │
│                            │               │                        │
│                            ▼               ▼                        │
│                     ┌──────────────────────────┐                    │
│                     │   ONBOARDING CHECK        │                    │
│                     │                           │                    │
│                     │  onboarding_completed?    │                    │
│                     └──────────┬───────────────┘                    │
│                                │                                     │
│                 No ────────────┼─────────── Yes                      │
│                 ▼              │              ▼                      │
│      ┌──────────────────┐     │     ┌──────────────────┐            │
│      │  ONBOARDING FLOW  │     │     │   MAIN APP FLOW  │            │
│      │                   │     │     │                  │            │
│      │ /onboarding/      │     │     │ /app/home        │            │
│      │   welcome         │     │     │ /app/discover    │            │
│      │ /onboarding/skin  │     │     │ /app/community   │            │
│      │ /onboarding/hair  │     │     │ /app/routine     │            │
│      │ /onboarding/      │     │     │ /app/profile     │            │
│      │   lifestyle       │     │     └──────────────────┘            │
│      │ /onboarding/goals │                                          │
│      └────────┬─────────┘                                            │
│               │                                                      │
│               │ Completed                                            │
│               └──────────► /app/home                                 │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │  DEEP LINKS (External Entry Points)                         │     │
│  │                                                             │     │
│  │  aura://product/{id}      → /products/:id                   │     │
│  │  aura://post/{id}         → /community/posts/:id            │     │
│  │  aura://challenge/{id}    → /community/challenges/:id       │     │
│  │  aura://routine/{id}      → /routines/:id                   │     │
│  │  aura://progress          → /progress                       │     │
│  │  aura://ai-coach          → /ai-coach/chat                  │     │
│  └────────────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. Auth Flow

```
┌───────────────────────────────────────────────────────────────────────┐
│                            AUTH FLOW                                   │
│                                                                       │
│  ┌───────────┐                                                        │
│  │ /splash   │                                                        │
│  │           │   Check flutter_secure_storage for token               │
│  └─────┬─────┘                                                        │
│        │                                                               │
│        ├── Token exists & valid ──────────────► /onboarding check     │
│        │                                                               │
│        └── No token / expired ───────────────► /auth/login            │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                     AUTH SCREENS                                │ │
│  │                                                                 │ │
│  │  ┌──────────────────┐    ┌──────────────────┐                   │ │
│  │  │  /auth/login     │    │ /auth/register   │                   │ │
│  │  │                  │    │                  │                   │ │
│  │  │  Email field     │    │  Name field      │                   │ │
│  │  │  Password field  │    │  Email field     │                   │ │
│  │  │  Login button    │    │  Password field  │                   │ │
│  │  │  Register link   │    │  Register btn    │                   │ │
│  │  │  Forgot pwd link │    │  Login link      │                   │ │
│  │  └────────┬─────────┘    └────────┬─────────┘                   │ │
│  │           │                      │                               │ │
│  │   ┌───────▼──────────────────────▼───────────┐                  │ │
│  │   │         /auth/forgot-password             │                  │ │
│  │   │  Email field + Send Reset Link button    │                  │ │
│  │   └──────────────────────────────────────────┘                  │ │
│  │                                                                 │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  Auth Events:                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  Login Success → Store api_key + api_secret in SecureStorage    │ │
│  │                → Update authProvider state                       │ │
│  │                → Redirect based on onboarding_completed          │ │
│  │                                                                 │ │
│  │  Register Success → Auto-login with returned credentials        │ │
│  │                   → Redirect to /onboarding/welcome              │ │
│  │                                                                 │ │
│  │  Logout → Clear SecureStorage                                   │ │
│  │          → Reset all Riverpod providers                         │ │
│  │          → Redirect to /auth/login                              │ │
│  │                                                                 │ │
│  │  Token Expired → Show session expired dialog                   │ │
│  │                 → Redirect to /auth/login                       │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────────┘
```

---

## 3. Onboarding Flow

```
┌───────────────────────────────────────────────────────────────────────┐
│                         ONBOARDING FLOW                                │
│                                                                       │
│  User registers → Redirected to /onboarding/welcome                   │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  STEP 1: /onboarding/welcome                                    │  │
│  │  ┌────────────────────────────────────────────┐                │  │
│  │  │  Welcome message with Aura branding         │                │  │
│  │  │  "Let's discover your beauty profile"       │                │  │
│  │  │  [Get Started] button                       │                │  │
│  │  └────────────────────────────────────────────┘                │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                               │                                       │
│                               ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  STEP 2: /onboarding/skin                                      │  │
│  │  ┌────────────────────────────────────────────┐                │  │
│  │  │  Section: Skin Conditions                   │                │  │
│  │  │  ○ Skin Type: [Oily|Dry|Combination|Normal] │                │  │
│  │  │  ○ Sensitivity: [Low|Medium|High]           │                │  │
│  │  │  ○ Acne: [None|Mild|Moderate|Severe]        │                │  │
│  │  │  ○ Pigmentation: [None|Low|Medium|High]     │                │  │
│  │  │  ○ Dark Spots: [None|Few|Moderate|Many]     │                │  │
│  │  │  Section: Aging Signs                        │                │  │
│  │  │  ○ Wrinkles, Fine Lines, Pores, Redness      │                │  │
│  │  │  Section: Hydration                          │                │  │
│  │  │  ○ Hydration Level: [Slider 0-100]           │                │  │
│  │  │  [Next] button                               │                │  │
│  │  └────────────────────────────────────────────┘                │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                               │                                       │
│                               ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  STEP 3: /onboarding/hair                                      │  │
│  │  ┌────────────────────────────────────────────┐                │  │
│  │  │  Section: Hair Profile                      │                │  │
│  │  │  ○ Hair Type: [Straight|Wavy|Curly|Coily]   │                │  │
│  │  │  ○ Texture: [Fine|Medium|Coarse]            │                │  │
│  │  │  ○ Thickness: [Thin|Medium|Thick]           │                │  │
│  │  │  ○ Density: [Low|Medium|High]               │                │  │
│  │  │  Section: Scalp & Hair Health                │                │  │
│  │  │  ○ Scalp, Hair Loss, Dandruff, Dryness       │                │  │
│  │  │  Section: Damage Assessment                  │                │  │
│  │  │  ○ Chemical treatments, Damage level         │                │  │
│  │  │  [Next] button                               │                │  │
│  │  └────────────────────────────────────────────┘                │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                               │                                       │
│                               ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  STEP 4: /onboarding/lifestyle                                  │  │
│  │  ┌────────────────────────────────────────────┐                │  │
│  │  │  ○ Sleep Quality: [Poor|Fair|Good|Excellent]│                │  │
│  │  │  ○ Water Intake: [Low|Medium|High]          │                │  │
│  │  │  ○ Activity: [Sedentary|Light|Moderate|Active]              │  │
│  │  │  ○ Stress Level: [Low|Medium|High]          │                │  │
│  │  │  ○ Sun Exposure: [Minimal|Moderate|Frequent]                │  │
│  │  │  [Next] button                               │                │  │
│  │  └────────────────────────────────────────────┘                │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                               │                                       │
│                               ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  STEP 5: /onboarding/goals                                     │  │
│  │  ┌────────────────────────────────────────────┐                │  │
│  │  │  "What are your beauty goals?"              │                │  │
│  │  │  Select all that apply:                      │                │  │
│  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐      │                │  │
│  │  │  │ Reduce  │ │ Anti-   │ │ Even    │      │                │  │
│  │  │  │ Acne    │ │ Aging   │ │ Skin    │      │                │  │
│  │  │  │         │ │         │ │ Tone    │      │                │  │
│  │  │  ├─────────┤ ├─────────┤ ├─────────┤      │                │  │
│  │  │  │ Hydrate │ │ Glow    │ │ Minimize│      │                │  │
│  │  │  │ Skin    │ │ Boost   │ │ Pores   │      │                │  │
│  │  │  ├─────────┤ ├─────────┤ ├─────────┤      │                │  │
│  │  │  │ Hair    │ │ Reduce  │ │ Stress  │      │                │  │
│  │  │  │ Growth  │ │ HairFall│ │ Relief  │      │                │  │
│  │  │  └─────────┘ └─────────┘ └─────────┘      │                │  │
│  │  │  [Complete Setup] button                    │                │  │
│  │  └────────────────────────────────────────────┘                │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                               │                                       │
│                               ▼                                       │
│                    Save all assessment data                            │
│                    Set onboarding_completed = true                    │
│                    Set profile.last_assessment_date = today           │
│                    Trigger recommendation generation                  │
│                               │                                       │
│                               ▼                                       │
│                    Redirect to /app/home                              │
└───────────────────────────────────────────────────────────────────────┘
```

---

## 4. Main App Flow (Tab Navigation)

```
┌──────────────────────────────────────────────────────────────────────┐
│                       MAIN APP TAB LAYOUT                              │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │  /app (ShellRoute)                                         │        │
│  │                                                           │        │
│  │  ┌─────────────────────────────────────────────────────┐  │        │
│  │  │  TAB 1: HOME  (/app/home)                          │  │        │
│  │  │  ┌─────────────────────────────────────────────────┐│  │        │
│  │  │  │  ● Aura Score Card (skin + hair scores)          ││  │        │
│  │  │  │  ● Quick Actions Grid:                           ││  │        │
│  │  │  │    [Assessment] [Products] [Routine] [Progress]  ││  │        │
│  │  │  │  ● "Recommended For You" carousel (horizontal)   ││  │        │
│  │  │  │  ● "Today's Routine" card with progress           ││  │        │
│  │  │  │  ● Trending Community Posts (2-3 cards)          ││  │        │
│  │  │  │  ● AI Coach quick ask bar                        ││  │        │
│  │  │  └─────────────────────────────────────────────────┘│  │        │
│  │  └─────────────────────────────────────────────────────┘  │        │
│  │                                                           │        │
│  │  ┌─────────────────────────────────────────────────────┐  │        │
│  │  │  TAB 2: DISCOVER (/app/discover)                    │  │        │
│  │  │  ┌─────────────────────────────────────────────────┐│  │        │
│  │  │  │  ● Search bar (navigates to /products/search)    ││  │        │
│  │  │  │  ● Category chips: [All] [Skincare] [Haircare]  ││  │        │
│  │  │  │    [Body] [Fragrance] [Featured]                 ││  │        │
│  │  │  │  ● Product grid (2 columns)                     ││  │        │
│  │  │  │    → Tap → /products/:id                        ││  │        │
│  │  │  │  ● Infinite scroll pagination                    ││  │        │
│  │  │  └─────────────────────────────────────────────────┘│  │        │
│  │  └─────────────────────────────────────────────────────┘  │        │
│  │                                                           │        │
│  │  ┌─────────────────────────────────────────────────────┐  │        │
│  │  │  TAB 3: COMMUNITY (/app/community)                  │  │        │
│  │  │  ┌─────────────────────────────────────────────────┐│  │        │
│  │  │  │  ● Tab bar: [For You] [Following]               ││  │        │
│  │  │  │  ● Post feed (vertically scrollable)            ││  │        │
│  │  │  │    → Tap → /community/posts/:id                 ││  │        │
│  │  │  │  ● FAB: Create Post                             ││  │        │
│  │  │  │  ● Group chips row (horizontal)                 ││  │        │
│  │  │  │    → Tap → /community/groups/:id                ││  │        │
│  │  │  │  ● Challenge banner (if active)                 ││  │        │
│  │  │  └─────────────────────────────────────────────────┘│  │        │
│  │  └─────────────────────────────────────────────────────┘  │        │
│  │                                                           │        │
│  │  ┌─────────────────────────────────────────────────────┐  │        │
│  │  │  TAB 4: ROUTINE (/app/routine)                      │  │        │
│  │  │  ┌─────────────────────────────────────────────────┐│  │        │
│  │  │  │  ● Date selector (today / tomorrow / custom)    ││  │        │
│  │  │  │  ● Section: Morning Routine                      ││  │        │
│  │  │  │    → Step cards with checkbox completion         ││  │        │
│  │  │  │  ● Section: Evening Routine                      ││  │        │
│  │  │  │    → Step cards with checkbox completion         ││  │        │
│  │  │  │  ● Section: Weekly Treatments                    ││  │        │
│  │  │  │  ● Completion percentage ring                   ││  │        │
│  │  │  │  ● [Create New Routine] button                   ││  │        │
│  │  │  └─────────────────────────────────────────────────┘│  │        │
│  │  └─────────────────────────────────────────────────────┘  │        │
│  │                                                           │        │
│  │  ┌─────────────────────────────────────────────────────┐  │        │
│  │  │  TAB 5: PROFILE (/app/profile)                      │  │        │
│  │  │  ┌─────────────────────────────────────────────────┐│  │        │
│  │  │  │  ● Profile header (name, avatar, member since)   ││  │        │
│  │  │  │  ● Stats row: [Assessments] [Posts] [Streak]    ││  │        │
│  │  │  │  ● Subscription status badge                     ││  │        │
│  │  │  │  ● Quick Links:                                  ││  │        │
│  │  │  │    → My Assessments → /assessments/history       ││  │        │
│  │  │  │    → My Progress → /progress                     ││  │        │
│  │  │  │    → My Routines → /routines                     ││  │        │
│  │  │  │    → AI Coach → /ai-coach/chat                   ││  │        │
│  │  │  │    → Subscription → /subscription                ││  │        │
│  │  │  │  ● Settings button → /settings                   ││  │        │
│  │  │  │  ● Dark mode toggle                              ││  │        │
│  │  │  │  ● Language selector                             ││  │        │
│  │  │  │  ● Logout button                                 ││  │        │
│  │  │  └─────────────────────────────────────────────────┘│  │        │
│  │  └─────────────────────────────────────────────────────┘  │        │
│  │                                                           │        │
│  │  ┌─────────────────────────────────────────────────────┐  │        │
│  │  │  BOTTOM NAVIGATION BAR                               │  │        │
│  │  │                                                       │  │        │
│  │  │  [🏠 Home] [🔍 Discover] [👥 Community] [📋 Routine] [👤 Profile] │  │
│  │  └─────────────────────────────────────────────────────┘  │        │
│  └──────────────────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 5. Deep Linking Structure

### URL Scheme

```
aura://<feature>/<action>/<id>
```

### Registered Deep Links

| Deep Link | Target Route | Description |
|---|---|---|
| `aura://product/{id}` | `/products/:id` | Open product detail |
| `aura://post/{id}` | `/community/posts/:id` | Open community post |
| `aura://challenge/{id}` | `/community/challenges/:id` | Open challenge |
| `aura://routine/{id}` | `/routines/:id` | Open routine detail |
| `aura://progress` | `/progress` | Open progress dashboard |
| `aura://ai-coach` | `/ai-coach/chat` | Open AI Coach chat |
| `aura://group/{id}` | `/community/groups/:id` | Open group detail |
| `aura://subscribe` | `/subscription` | Open subscription plans |

### Push Notification Deep Links

```json
{
  "notification": {
    "title": "Your routine is ready!",
    "body": "Today's personalized routine is waiting."
  },
  "data": {
    "route": "/app/routine",
    "type": "routine_ready"
  }
}
```

### Deep Link Handling

```dart
// GoRouter redirect logic for deep links
final router = GoRouter(
  initialLocation: '/splash',
  routes: [...],
  redirect: (context, state) {
    // Handle deep links from push notifications
    final deepLink = state.uri.queryParameters['deep_link'];
    if (deepLink != null) {
      return deepLink;
    }
    return null;
  },
);
```

---

## 6. Route Definitions

### Complete Route Table

```dart
final router = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  redirect: (context, state) => _handleAuthRedirect(context, state),
  routes: [
    // Splash
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

    // Auth
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/auth/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

    // Onboarding
    GoRoute(path: '/onboarding/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/onboarding/skin', builder: (_, __) => const SkinAssessmentScreen()),
    GoRoute(path: '/onboarding/hair', builder: (_, __) => const HairAssessmentScreen()),
    GoRoute(path: '/onboarding/lifestyle', builder: (_, __) => const LifestyleAssessmentScreen()),
    GoRoute(path: '/onboarding/goals', builder: (_, __) => const GoalSelectionScreen()),

    // Main App Shell (Bottom Navigation)
    ShellRoute(
      builder: (_, __, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/app/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/app/discover', builder: (_, __) => const DiscoverScreen()),
        GoRoute(path: '/app/community', builder: (_, __) => const CommunityScreen()),
        GoRoute(path: '/app/routine', builder: (_, __) => const RoutineScreen()),
        GoRoute(path: '/app/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // Products
    GoRoute(path: '/products', builder: (_, __) => const ProductListScreen()),
    GoRoute(path: '/products/:id', builder: (_, state) => ProductDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/products/search', builder: (_, __) => const ProductSearchScreen()),

    // Assessments
    GoRoute(path: '/assessments/skin', builder: (_, __) => const SkinAssessmentScreen()),
    GoRoute(path: '/assessments/hair', builder: (_, __) => const HairAssessmentScreen()),
    GoRoute(path: '/assessments/lifestyle', builder: (_, __) => const LifestyleAssessmentScreen()),
    GoRoute(path: '/assessments/history', builder: (_, __) => const AssessmentHistoryScreen()),

    // Community
    GoRoute(path: '/community/posts/:id', builder: (_, state) => PostDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/community/create', builder: (_, __) => const CreatePostScreen()),
    GoRoute(path: '/community/groups', builder: (_, __) => const GroupsScreen()),
    GoRoute(path: '/community/groups/:id', builder: (_, state) => GroupDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/community/challenges', builder: (_, __) => const ChallengesScreen()),
    GoRoute(path: '/community/challenges/:id', builder: (_, state) => ChallengeDetailScreen(id: state.pathParameters['id']!)),

    // Routines
    GoRoute(path: '/routines', builder: (_, __) => const RoutineListScreen()),
    GoRoute(path: '/routines/:id', builder: (_, state) => RoutineDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/routines/create', builder: (_, __) => const CreateRoutineScreen()),

    // Progress
    GoRoute(path: '/progress', builder: (_, __) => const ProgressDashboardScreen()),
    GoRoute(path: '/progress/add', builder: (_, __) => const AddProgressEntryScreen()),
    GoRoute(path: '/progress/skin', builder: (_, __) => const SkinProgressChartScreen()),
    GoRoute(path: '/progress/hair', builder: (_, __) => const HairProgressChartScreen()),
    GoRoute(path: '/progress/lifestyle', builder: (_, __) => const LifestyleProgressScreen()),

    // AI Coach
    GoRoute(path: '/ai-coach/chat', builder: (_, __) => const AICoachChatScreen()),

    // Subscription
    GoRoute(path: '/subscription', builder: (_, __) => const SubscriptionScreen()),
    GoRoute(path: '/subscription/checkout', builder: (_, __) => const CheckoutScreen()),

    // Settings
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/settings/profile', builder: (_, __) => const EditProfileScreen()),

    // Notifications
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
  ],
);
```

---

## 7. State-Based Redirects

### Auth Redirect Guard

```dart
Future<String?> _handleAuthRedirect(BuildContext context, GoRouterState state) async {
  final isLoggedIn = ref.read(authProvider).isAuthenticated;
  final isOnboardingComplete = ref.read(profileProvider).onboardingCompleted;
  final currentPath = state.matchedLocation;

  // Allow access to auth routes when not logged in
  final authRoutes = ['/auth/login', '/auth/register', '/auth/forgot-password'];
  if (!isLoggedIn && authRoutes.contains(currentPath)) return null;
  if (!isLoggedIn && currentPath == '/splash') return null;

  // Redirect to login if not authenticated
  if (!isLoggedIn) return '/auth/login';

  // Allow splash and onboarding when logged in
  if (currentPath == '/splash') return null;
  if (currentPath.startsWith('/onboarding')) return null;

  // Redirect to onboarding if not completed
  if (!isOnboardingComplete && !currentPath.startsWith('/onboarding')) {
    return '/onboarding/welcome';
  }

  // Redirect to home if onboarding is complete and on auth pages
  if (isOnboardingComplete && authRoutes.contains(currentPath)) {
    return '/app/home';
  }

  return null; // No redirect needed
}
```

### Redirect Decision Matrix

| Auth State | Onboarding | Current Route | Redirect To |
|---|---|---|---|
| Not logged in | - | `/splash` | No redirect |
| Not logged in | - | `/auth/login` | No redirect |
| Not logged in | - | `/auth/register` | No redirect |
| Not logged in | - | `/app/home` | `/auth/login` |
| Not logged in | - | `/products` | `/auth/login` |
| Logged in | False | `/app/home` | `/onboarding/welcome` |
| Logged in | False | `/community` | `/onboarding/welcome` |
| Logged in | False | `/onboarding/welcome` | No redirect |
| Logged in | True | `/auth/login` | `/app/home` |
| Logged in | True | `/app/home` | No redirect |
| Logged in | True | `/products/123` | No redirect |
| Logged in | True | Any valid route | No redirect |
| Token expired | - | Any protected route | `/auth/login` |

### Push Notification Redirect

```dart
// When app receives push notification
void handleNotificationTap(Map<String, dynamic> data) {
  final route = data['route'] as String?;
  if (route != null) {
    router.go(route);
  }
}
```

---

## Navigation Flow Summary

```
┌──────────────────────────────────────────────────────────────────────┐
│                    NAVIGATION INVARIANT CHECKLIST                      │
│                                                                       │
│  Every navigation transition must ensure:                             │
│                                                                       │
│  ☐ User is authenticated (or on auth route)                          │
│  ☐ Onboarding is complete (or on onboarding route)                   │
│  ☐ Deep link target exists (or show 404/empty state)                 │
│  ☐ Subscription feature gate passed (for premium features)           │
│  ☐ Previous route state is preserved in navigation stack             │
│  ☐ Bottom nav tab reflects current active tab                        │
│  ☐ Back button returns to appropriate previous screen                │
│                                                                       │
│  Platform-specific behavior:                                          │
│  ┌───────────────────┬──────────────────────────────────────────┐    │
│  │ Android           │ Back button pops route stack              │    │
│  │                   │ Long press back shows route history       │    │
│  ├───────────────────┼──────────────────────────────────────────┤    │
│  │ iOS               │ Swipe back gesture navigates back        │    │
│  │                   │ No system back button                    │    │
│  ├───────────────────┼──────────────────────────────────────────┤    │
│  │ Deep Links        │ Resolved after auth + onboarding check   │    │
│  │                   │ Stored in queue if not yet ready         │    │
│  └───────────────────┴──────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘
```
