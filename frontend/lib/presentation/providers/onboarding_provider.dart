import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class PersonalInfo {
  final String name;
  final String ageRange;
  final String gender;
  final String country;
  final String climate;

  const PersonalInfo({
    this.name = '',
    this.ageRange = '',
    this.gender = '',
    this.country = '',
    this.climate = '',
  });

  PersonalInfo copyWith({
    String? name,
    String? ageRange,
    String? gender,
    String? country,
    String? climate,
  }) {
    return PersonalInfo(
      name: name ?? this.name,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      climate: climate ?? this.climate,
    );
  }
}

class SkinAssessment {
  final String skinType;
  final String sensitivity;
  final String acne;
  final String pigmentation;
  final String wrinkles;
  final List<String> goals;

  const SkinAssessment({
    this.skinType = '',
    this.sensitivity = '',
    this.acne = '',
    this.pigmentation = '',
    this.wrinkles = '',
    this.goals = const [],
  });

  SkinAssessment copyWith({
    String? skinType,
    String? sensitivity,
    String? acne,
    String? pigmentation,
    String? wrinkles,
    List<String>? goals,
  }) {
    return SkinAssessment(
      skinType: skinType ?? this.skinType,
      sensitivity: sensitivity ?? this.sensitivity,
      acne: acne ?? this.acne,
      pigmentation: pigmentation ?? this.pigmentation,
      wrinkles: wrinkles ?? this.wrinkles,
      goals: goals ?? this.goals,
    );
  }
}

class HairAssessment {
  final String hairType;
  final String texture;
  final String thickness;
  final String density;
  final String scalpCondition;
  final List<String> issues;
  final List<String> goals;

  const HairAssessment({
    this.hairType = '',
    this.texture = '',
    this.thickness = '',
    this.density = '',
    this.scalpCondition = '',
    this.issues = const [],
    this.goals = const [],
  });

  HairAssessment copyWith({
    String? hairType,
    String? texture,
    String? thickness,
    String? density,
    String? scalpCondition,
    List<String>? issues,
    List<String>? goals,
  }) {
    return HairAssessment(
      hairType: hairType ?? this.hairType,
      texture: texture ?? this.texture,
      thickness: thickness ?? this.thickness,
      density: density ?? this.density,
      scalpCondition: scalpCondition ?? this.scalpCondition,
      issues: issues ?? this.issues,
      goals: goals ?? this.goals,
    );
  }
}

class LifestyleAssessment {
  final String sleepQuality;
  final String waterIntake;
  final String activityLevel;
  final String stressLevel;
  final String sunExposure;

  const LifestyleAssessment({
    this.sleepQuality = '',
    this.waterIntake = '',
    this.activityLevel = '',
    this.stressLevel = '',
    this.sunExposure = '',
  });

  LifestyleAssessment copyWith({
    String? sleepQuality,
    String? waterIntake,
    String? activityLevel,
    String? stressLevel,
    String? sunExposure,
  }) {
    return LifestyleAssessment(
      sleepQuality: sleepQuality ?? this.sleepQuality,
      waterIntake: waterIntake ?? this.waterIntake,
      activityLevel: activityLevel ?? this.activityLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      sunExposure: sunExposure ?? this.sunExposure,
    );
  }
}

class OnboardingState {
  final int currentStep;
  final PersonalInfo personalInfo;
  final SkinAssessment skinAssessment;
  final HairAssessment hairAssessment;
  final LifestyleAssessment lifestyleAssessment;
  final bool isSubmitting;
  final bool isComplete;

  const OnboardingState({
    this.currentStep = 0,
    this.personalInfo = const PersonalInfo(),
    this.skinAssessment = const SkinAssessment(),
    this.hairAssessment = const HairAssessment(),
    this.lifestyleAssessment = const LifestyleAssessment(),
    this.isSubmitting = false,
    this.isComplete = false,
  });
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  late PageController _pageController;

  PageController get pageController => _pageController;

  OnboardingNotifier() : super(const OnboardingState()) {
    _pageController = PageController();
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      state = OnboardingState(
        currentStep: step,
        personalInfo: state.personalInfo,
        skinAssessment: state.skinAssessment,
        hairAssessment: state.hairAssessment,
        lifestyleAssessment: state.lifestyleAssessment,
      );
    }
  }

  void nextStep() {
    if (state.currentStep < 4) {
      goToStep(state.currentStep + 1);
      _pageController.animateToPage(
        state.currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      final newStep = state.currentStep - 1;
      state = OnboardingState(
        currentStep: newStep,
        personalInfo: state.personalInfo,
        skinAssessment: state.skinAssessment,
        hairAssessment: state.hairAssessment,
        lifestyleAssessment: state.lifestyleAssessment,
      );
      _pageController.animateToPage(
        newStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void updatePersonalInfo({
    String? name,
    String? ageRange,
    String? gender,
    String? country,
    String? climate,
  }) {
    state = OnboardingState(
      currentStep: state.currentStep,
      personalInfo: state.personalInfo.copyWith(
        name: name,
        ageRange: ageRange,
        gender: gender,
        country: country,
        climate: climate,
      ),
      skinAssessment: state.skinAssessment,
      hairAssessment: state.hairAssessment,
      lifestyleAssessment: state.lifestyleAssessment,
    );
  }

  void updateSkinAssessment({
    String? skinType,
    String? sensitivity,
    String? acne,
    String? pigmentation,
    String? wrinkles,
    List<String>? goals,
  }) {
    state = OnboardingState(
      currentStep: state.currentStep,
      personalInfo: state.personalInfo,
      skinAssessment: state.skinAssessment.copyWith(
        skinType: skinType,
        sensitivity: sensitivity,
        acne: acne,
        pigmentation: pigmentation,
        wrinkles: wrinkles,
        goals: goals,
      ),
      hairAssessment: state.hairAssessment,
      lifestyleAssessment: state.lifestyleAssessment,
    );
  }

  void toggleSkinGoal(String goal) {
    final currentGoals = List<String>.from(state.skinAssessment.goals);
    if (currentGoals.contains(goal)) {
      currentGoals.remove(goal);
    } else {
      currentGoals.add(goal);
    }
    updateSkinAssessment(goals: currentGoals);
  }

  void updateHairAssessment({
    String? hairType,
    String? texture,
    String? thickness,
    String? density,
    String? scalpCondition,
    List<String>? issues,
    List<String>? goals,
  }) {
    state = OnboardingState(
      currentStep: state.currentStep,
      personalInfo: state.personalInfo,
      skinAssessment: state.skinAssessment,
      hairAssessment: state.hairAssessment.copyWith(
        hairType: hairType,
        texture: texture,
        thickness: thickness,
        density: density,
        scalpCondition: scalpCondition,
        issues: issues,
        goals: goals,
      ),
      lifestyleAssessment: state.lifestyleAssessment,
    );
  }

  void toggleHairIssue(String issue) {
    final currentIssues = List<String>.from(state.hairAssessment.issues);
    if (currentIssues.contains(issue)) {
      currentIssues.remove(issue);
    } else {
      currentIssues.add(issue);
    }
    updateHairAssessment(issues: currentIssues);
  }

  void toggleHairGoal(String goal) {
    final currentGoals = List<String>.from(state.hairAssessment.goals);
    if (currentGoals.contains(goal)) {
      currentGoals.remove(goal);
    } else {
      currentGoals.add(goal);
    }
    updateHairAssessment(goals: currentGoals);
  }

  void updateLifestyleAssessment({
    String? sleepQuality,
    String? waterIntake,
    String? activityLevel,
    String? stressLevel,
    String? sunExposure,
  }) {
    state = OnboardingState(
      currentStep: state.currentStep,
      personalInfo: state.personalInfo,
      skinAssessment: state.skinAssessment,
      hairAssessment: state.hairAssessment,
      lifestyleAssessment: state.lifestyleAssessment.copyWith(
        sleepQuality: sleepQuality,
        waterIntake: waterIntake,
        activityLevel: activityLevel,
        stressLevel: stressLevel,
        sunExposure: sunExposure,
      ),
    );
  }

  Future<void> submitAll() async {
    state = OnboardingState(
      currentStep: state.currentStep,
      personalInfo: state.personalInfo,
      skinAssessment: state.skinAssessment,
      hairAssessment: state.hairAssessment,
      lifestyleAssessment: state.lifestyleAssessment,
      isSubmitting: true,
    );
    try {
      final api = ApiClient();
      await api.post(ApiConstants.submitAssessment, data: {
        'assessment_type': 'Skin',
        'data': {
          'skin_type': state.skinAssessment.skinType,
          'sensitivity': state.skinAssessment.sensitivity,
          'acne': state.skinAssessment.acne,
          'pigmentation': state.skinAssessment.pigmentation,
          'wrinkles': state.skinAssessment.wrinkles,
          'goals': state.skinAssessment.goals,
        },
      });
      await api.post(ApiConstants.submitAssessment, data: {
        'assessment_type': 'Hair',
        'data': {
          'hair_type': state.hairAssessment.hairType,
          'texture': state.hairAssessment.texture,
          'thickness': state.hairAssessment.thickness,
          'density': state.hairAssessment.density,
          'scalp_condition': state.hairAssessment.scalpCondition,
          'issues': state.hairAssessment.issues,
          'goals': state.hairAssessment.goals,
        },
      });
      await api.post(ApiConstants.submitAssessment, data: {
        'assessment_type': 'Lifestyle',
        'data': {
          'sleep_quality': state.lifestyleAssessment.sleepQuality,
          'water_intake': state.lifestyleAssessment.waterIntake,
          'activity_level': state.lifestyleAssessment.activityLevel,
          'stress_level': state.lifestyleAssessment.stressLevel,
          'sun_exposure': state.lifestyleAssessment.sunExposure,
        },
      });
      state = OnboardingState(
        currentStep: state.currentStep,
        personalInfo: state.personalInfo,
        skinAssessment: state.skinAssessment,
        hairAssessment: state.hairAssessment,
        lifestyleAssessment: state.lifestyleAssessment,
        isSubmitting: false,
        isComplete: true,
      );
    } catch (_) {
      state = OnboardingState(
        currentStep: state.currentStep,
        personalInfo: state.personalInfo,
        skinAssessment: state.skinAssessment,
        hairAssessment: state.hairAssessment,
        lifestyleAssessment: state.lifestyleAssessment,
        isSubmitting: false,
      );
    }
  }

  void dispose() {
    _pageController.dispose();
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});
