import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/dashboard/domain/entities/dashboard_stats_entity.dart';

abstract class DashboardRepository {
  /// Fetch dashboard stats computed from real API data.
  Future<Either<Failure, DashboardStatsEntity>> getStats();
}
