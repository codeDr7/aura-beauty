import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/discover/discover_screen.dart';
import '../../presentation/screens/community/community_screen.dart';
import '../../presentation/screens/progress/progress_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/routine/routine_screen.dart';
import '../../presentation/screens/ai_coach/ai_coach_screen.dart';
import '../../presentation/screens/community/challenge_detail_screen.dart';
import '../../presentation/screens/community/post_detail_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/subscription/subscription_screen.dart';
import '../../presentation/screens/diary/beauty_diary_screen.dart';
import '../../presentation/screens/routine/routine_timer_screen.dart';
import '../../presentation/screens/badges/badges_screen.dart';
import '../../presentation/screens/ingredients/ingredient_checker_screen.dart';
import '../../presentation/screens/analysis/skin_analysis_screen.dart';
import '../../presentation/screens/alerts/price_alerts_screen.dart';
import '../../presentation/screens/marketplace/marketplace_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../../presentation/widgets/common/aura_bottom_nav.dart';

const String _initialLocation = '/splash';

class AppRouter {
  AppRouter(Ref ref) : _router = _createRouter(ref);

  final GoRouter _router;

  GoRouter get config => _router;

  static GoRouter _createRouter(Ref ref) {
    return GoRouter(
      initialLocation: _initialLocation,
      debugLogDiagnostics: false,
      redirect: (context, state) => _authRedirect(context, state),
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RegisterScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return _MainShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const HomeScreen(),
              ),
            ),
            GoRoute(
              path: '/discover',
              name: 'discover',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const DiscoverScreen(),
              ),
            ),
            GoRoute(
              path: '/community',
              name: 'community',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const CommunityScreen(),
              ),
            ),
            GoRoute(
              path: '/progress',
              name: 'progress',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const ProgressScreen(),
              ),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/routine/:id',
          name: 'routineDetail',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoutineScreen(
              routineId: state.pathParameters['id'] ?? '',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'productDetail',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: _ProductDetailPlaceholder(
              id: state.pathParameters['id'] ?? '',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/ai-coach',
          name: 'aiCoach',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AiCoachScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/challenge/:id',
          name: 'challengeDetail',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: ChallengeDetailScreen(
              challengeId: state.pathParameters['id'] ?? '',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/group/:id',
          name: 'groupDetail',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: _GroupDetailPlaceholder(
              id: state.pathParameters['id'] ?? '',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/post/:id',
          name: 'postDetail',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: PostDetailScreen(
              postId: state.pathParameters['id'] ?? '',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/subscription',
          name: 'subscription',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SubscriptionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        // New Feature Routes
        GoRoute(
          path: '/diary',
          name: 'diary',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const BeautyDiaryScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/routine-timer/:id',
          name: 'routineTimer',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoutineTimerScreen(
              routineId: state.pathParameters['id'] ?? '',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/badges',
          name: 'badges',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const BadgesScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/ingredients',
          name: 'ingredients',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const IngredientCheckerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/skin-analysis',
          name: 'skinAnalysis',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SkinAnalysisScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/price-alerts',
          name: 'priceAlerts',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const PriceAlertsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/marketplace',
          name: 'marketplace',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const MarketplaceScreen(initialTab: 0),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/marketplace/partner',
          name: 'marketplacePartner',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const MarketplaceScreen(initialTab: 1),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
          ),
        ),
      ],
    );
  }

  static String? _authRedirect(BuildContext context, GoRouterState state) {
    final isOnSplash = state.matchedLocation == '/splash';
    if (isOnSplash) return null;

    final isLoggedIn = false;
    final isOnAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    final isOnOnboarding = state.matchedLocation.startsWith('/onboarding');

    if (!isLoggedIn && !isOnAuthRoute && !isOnOnboarding) {
      return '/login';
    }

    if (isLoggedIn && isOnAuthRoute) {
      return '/home';
    }

    return null;
  }
}

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  int _currentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/discover')) return 1;
    if (location.startsWith('/community')) return 2;
    if (location.startsWith('/progress')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: AuraBottomNav(
        currentIndex: index,
      ),
    );
  }
}

class _ProductDetailPlaceholder extends StatelessWidget {
  final String id;
  const _ProductDetailPlaceholder({required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Center(child: Text('Product: $id')),
    );
  }
}

class _GroupDetailPlaceholder extends StatelessWidget {
  final String id;
  const _GroupDetailPlaceholder({required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Detail')),
      body: Center(child: Text('Group: $id')),
    );
  }
}
