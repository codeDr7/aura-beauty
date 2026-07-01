import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/community.dart';
import '../../domain/entities/routine.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/routine_repository.dart';
import '../../domain/repositories/community_repository.dart';
import '../providers/repository_providers.dart';

class HomeState {
  final String greeting;
  final int skinScore;
  final int hairScore;
  final List<Routine> routines;
  final List<Product> recommendations;
  final List<Challenge> challenges;
  final List<CommunityPost> highlights;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.greeting = 'Good morning',
    this.skinScore = 0,
    this.hairScore = 0,
    this.routines = const [],
    this.recommendations = const [],
    this.challenges = const [],
    this.highlights = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    String? greeting,
    int? skinScore,
    int? hairScore,
    List<Routine>? routines,
    List<Product>? recommendations,
    List<Challenge>? challenges,
    List<CommunityPost>? highlights,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      greeting: greeting ?? this.greeting,
      skinScore: skinScore ?? this.skinScore,
      hairScore: hairScore ?? this.hairScore,
      routines: routines ?? this.routines,
      recommendations: recommendations ?? this.recommendations,
      challenges: challenges ?? this.challenges,
      highlights: highlights ?? this.highlights,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final ProductRepository _productRepo;
  final RoutineRepository _routineRepo;
  final CommunityRepository _communityRepo;

  HomeNotifier(this._productRepo, this._routineRepo, this._communityRepo) : super(const HomeState()) {
    loadHomeData();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _productRepo.getProducts().catchError((_) => <Product>[]);
      final routines = await _routineRepo.getRoutines().catchError((_) => <Routine>[]);
      final feed = await _communityRepo.getFeed(page: 1, limit: 3).catchError((_) => <CommunityPost>[]);
      final challenges = await _communityRepo.getChallenges().catchError((_) => <Challenge>[]);

      final recommended = products.where((p) => p.isRecommended).toList();
      final topRecs = recommended.isNotEmpty ? recommended : products.take(6).toList();

      state = state.copyWith(
        greeting: _getGreeting(),
        skinScore: 72,
        hairScore: 65,
        routines: routines,
        recommendations: topRecs,
        highlights: feed.take(2).toList(),
        challenges: challenges,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(
    ref.watch(productRepositoryProvider),
    ref.watch(routineRepositoryProvider),
    ref.watch(communityRepositoryProvider),
  );
});
