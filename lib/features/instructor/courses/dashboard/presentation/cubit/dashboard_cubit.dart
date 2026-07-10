import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

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

  const DashboardLoaded(this.stats);
  final DashboardStatsEntity stats;

  @override
  List<Object?> get props => [stats];
}

class DashboardError extends DashboardState {

  const DashboardError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ----- Cubit -----

class DashboardCubit extends Cubit<DashboardState> {

  DashboardCubit({required this.getDashboardStatsUseCase})
      : super(const DashboardInitial());
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  Future<void> getStats(UserRole role) async {
    emit(const DashboardLoading());
    final result = await getDashboardStatsUseCase(role);
    result.fold(
      (failure) => emit(DashboardError(_mapFailureToMessage(failure))),
      (stats) => emit(DashboardLoaded(stats)),
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
