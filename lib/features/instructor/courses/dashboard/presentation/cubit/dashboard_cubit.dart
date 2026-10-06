import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:lms/features/instructor/storage/domain/entities/storage_entities.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_revenue_usecase.dart';

// ----- States -----

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {

  const DashboardLoaded(this.stats, {this.revenue});
  final DashboardStatsEntity stats;
  final RevenueSummary? revenue;

  @override
  List<Object?> get props => [stats, revenue];
}

class DashboardError extends DashboardState {

  const DashboardError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ----- Cubit -----

class DashboardCubit extends Cubit<DashboardState> {

  DashboardCubit({
    required this.getDashboardStatsUseCase,
    this.getRevenueUseCase,
  }) : super(const DashboardInitial());
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetRevenueUseCase? getRevenueUseCase;

  /// Fetches dashboard stats. With [silent] the current content stays
  /// visible while refreshing (used by pull-to-refresh).
  Future<void> getStats(UserRole role, {bool silent = false}) async {
    if (!silent || state is! DashboardLoaded) {
      emit(const DashboardLoading());
    }
    final result = await getDashboardStatsUseCase(role);
    result.fold(
      (failure) => emit(DashboardError(_mapFailureToMessage(failure))),
      (stats) async {
        RevenueSummary? revenue;
        if (role == UserRole.instructor && getRevenueUseCase != null) {
          final revenueResult = await getRevenueUseCase!();
          revenueResult.fold((_) {}, (r) => revenue = r);
        }
        emit(DashboardLoaded(stats, revenue: revenue));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure f => f.message,
      _ => 'An unexpected error occurred',
    };
  }
}
