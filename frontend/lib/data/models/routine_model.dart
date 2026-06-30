import '../../domain/entities/routine.dart';

class RoutineModel extends Routine {
  const RoutineModel({
    required super.id,
    required super.name,
    required super.type,
    required super.steps,
    super.progress,
    super.streak,
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['name'] as String? ?? '',
      name: json['routine_template'] as String? ?? '',
      type: json['type'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => RoutineStepModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      progress: (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
      streak: json['streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'routine_template': name,
    'steps': (steps as List<RoutineStepModel>).map((s) => s.toJson()).toList(),
  };
}

class RoutineStepModel extends RoutineStep {
  const RoutineStepModel({
    required super.id,
    required super.title,
    required super.product,
    super.productId,
    super.durationSeconds,
    super.isCompleted,
    super.order,
  });

  factory RoutineStepModel.fromJson(Map<String, dynamic> json) {
    return RoutineStepModel(
      id: json['step_name'] as String? ?? '',
      title: json['step_name'] as String? ?? '',
      product: json['product'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      durationSeconds: (json['duration_minutes'] as int? ?? 2) * 60,
      isCompleted: json['is_completed'] as bool? ?? false,
      order: json['step_number'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'step_name': title,
    'product': product,
    'duration_minutes': durationSeconds ~/ 60,
    'is_completed': isCompleted,
    'step_number': order,
  };
}
