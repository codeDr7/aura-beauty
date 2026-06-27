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
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => RoutineStepModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      streak: json['streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'steps': (steps as List<RoutineStepModel>).map((s) => s.toJson()).toList(),
    'progress': progress,
    'streak': streak,
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
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      product: json['product'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      durationSeconds: json['duration_seconds'] as int? ?? 60,
      isCompleted: json['is_completed'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'product': product,
    'product_id': productId,
    'duration_seconds': durationSeconds,
    'is_completed': isCompleted,
    'order': order,
  };
}
