import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:lms/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<Either<Failure, DashboardStatsEntity>> call() {
    return repository.getStats();
  }
}
