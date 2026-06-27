import 'package:equatable/equatable.dart';

class Badge extends Equatable {
  final String id;
  final String name;
  final String category;
  final bool isEarned;
  final double progress;
  final String? description;
  final String? iconName;

  const Badge({
    required this.id,
    required this.name,
    required this.category,
    this.isEarned = false,
    this.progress = 0.0,
    this.description,
    this.iconName,
  });

  @override
  List<Object?> get props => [id, name, category, isEarned, progress, description, iconName];
}
