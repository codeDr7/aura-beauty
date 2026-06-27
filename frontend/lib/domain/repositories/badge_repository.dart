import '../entities/badge.dart';

abstract class BadgeRepository {
  Future<List<Badge>> getBadges({String? category});
  Future<List<String>> getCategories();
}
