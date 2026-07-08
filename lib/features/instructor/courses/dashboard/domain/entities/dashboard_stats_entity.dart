import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  final int enrolledCourses;
  final int completedCourses;
  final int totalLessonsCompleted;
  final int totalMinutesLearned;
  final double overallProgress;

  const DashboardStatsEntity({
    this.enrolledCourses = 0,
    this.completedCourses = 0,
    this.totalLessonsCompleted = 0,
    this.totalMinutesLearned = 0,
    this.overallProgress = 0,
  });

  @override
  List<Object?> get props => [
        enrolledCourses,
        completedCourses,
        totalLessonsCompleted,
        totalMinutesLearned,
        overallProgress,
      ];
}
