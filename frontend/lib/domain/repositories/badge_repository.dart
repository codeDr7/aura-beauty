import '../entities/badge.dart';

abstract class BadgeRepository {
  Future<List<Badge>> getMyBadges();
  Future<List<Badge>> getAllBadges();
}
