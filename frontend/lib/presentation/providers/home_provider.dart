import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoutineItem {
  final String name;
  final String type;
  final double progress;
  final List<String> steps;

  const RoutineItem({
    required this.name,
    required this.type,
    required this.progress,
    required this.steps,
  });
}

class ProductRecommendation {
  final String name;
  final String subtitle;
  final String price;
  final String? badgeLabel;
  final String imageUrl;

  const ProductRecommendation({
    required this.name,
    required this.subtitle,
    required this.price,
    this.badgeLabel,
    this.imageUrl = '',
  });
}

class ChallengeItem {
  final String title;
  final String description;
  final int duration;
  final int remaining;
  final double progress;
  final int participants;

  const ChallengeItem({
    required this.title,
    required this.description,
    required this.duration,
    required this.remaining,
    required this.progress,
    required this.participants,
  });
}

class CommunityHighlight {
  final String userName;
  final String content;
  final int likes;
  final int comments;

  const CommunityHighlight({
    required this.userName,
    required this.content,
    required this.likes,
    required this.comments,
  });
}

class HomeState {
  final String greeting;
  final String userName;
  final int skinScore;
  final int hairScore;
  final List<RoutineItem> routines;
  final List<ProductRecommendation> recommendations;
  final List<ChallengeItem> challenges;
  final List<CommunityHighlight> highlights;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.greeting = 'Good morning',
    this.userName = 'Sarah',
    this.skinScore = 72,
    this.hairScore = 65,
    this.routines = const [],
    this.recommendations = const [],
    this.challenges = const [],
    this.highlights = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    String? greeting,
    String? userName,
    int? skinScore,
    int? hairScore,
    List<RoutineItem>? routines,
    List<ProductRecommendation>? recommendations,
    List<ChallengeItem>? challenges,
    List<CommunityHighlight>? highlights,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      greeting: greeting ?? this.greeting,
      userName: userName ?? this.userName,
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
  HomeNotifier() : super(const HomeState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    state = state.copyWith(
      greeting: greeting,
      routines: [
        RoutineItem(name: 'Morning', type: 'Cleanse • Tone • Moisturize', progress: 0.6, steps: ['Cleanse', 'Tone', 'Moisturize', 'SPF']),
        RoutineItem(name: 'Evening', type: 'Double Cleanse • Serum • Cream', progress: 0.3, steps: ['Double Cleanse', 'Serum', 'Night Cream']),
      ],
      recommendations: [
        ProductRecommendation(name: 'Hydrating Serum', subtitle: 'Vitamin C + HA', price: '\$48.00', badgeLabel: 'Best Seller'),
        ProductRecommendation(name: 'Retinol Night Cream', subtitle: 'Anti-Aging', price: '\$65.00', badgeLabel: 'New'),
        ProductRecommendation(name: 'Gentle Cleanser', subtitle: 'For Sensitive Skin', price: '\$32.00'),
      ],
      challenges: [
        ChallengeItem(title: '14-Day Glow Journey', description: 'Complete your daily routine', duration: 14, remaining: 3, progress: 0.64, participants: 1240),
      ],
      highlights: [
        CommunityHighlight(userName: 'Aisha M.', content: 'Just completed my 14-day glow challenge! My skin has never looked better ✨', likes: 42, comments: 12),
      ],
    );
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    _loadInitialData();
    state = state.copyWith(isLoading: false);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
