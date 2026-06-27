import 'package:equatable/equatable.dart';

class Routine extends Equatable {
  final String id;
  final String name;
  final String type;
  final List<RoutineStep> steps;
  final double progress;
  final int streak;

  const Routine({
    required this.id,
    required this.name,
    required this.type,
    required this.steps,
    this.progress = 0.0,
    this.streak = 0,
  });

  @override
  List<Object?> get props => [id, name, type, steps, progress, streak];
}

class RoutineStep extends Equatable {
  final String id;
  final String title;
  final String product;
  final String productId;
  final int durationSeconds;
  final bool isCompleted;
  final int order;

  const RoutineStep({
    required this.id,
    required this.title,
    required this.product,
    this.productId = '',
    this.durationSeconds = 60,
    this.isCompleted = false,
    this.order = 0,
  });

  RoutineStep copyWith({bool? isCompleted}) {
    return RoutineStep(
      id: id,
      title: title,
      product: product,
      productId: productId,
      durationSeconds: durationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order,
    );
  }

  @override
  List<Object?> get props => [id, title, product, productId, durationSeconds, isCompleted, order];
}
