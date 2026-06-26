import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/dashboard/domain/entities/dashboard_stats_entity.dart';

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
  final DashboardStatsEntity stats;

  const DashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// ----- Events -----

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class GetDashboardStatsEvent extends DashboardEvent {
  const GetDashboardStatsEvent();
}

// ----- Cubit -----

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardInitial());

  Future<void> getStats() async {
    emit(const DashboardLoading());
    // TODO: Implement with real data source
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const DashboardLoaded(DashboardStatsEntity(
      enrolledCourses: 5,
      completedCourses: 2,
      totalLessonsCompleted: 24,
      totalMinutesLearned: 360,
      overallProgress: 40,
    )));
  }
}
