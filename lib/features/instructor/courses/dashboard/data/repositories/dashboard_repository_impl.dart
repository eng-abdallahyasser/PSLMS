import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/instructor/courses/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final DashboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, DashboardStatsEntity>> getStats(UserRole role) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final courses = await remoteDataSource.getCourses(role: role);

      if (role == UserRole.instructor) {
        final totalCourses = courses.length;
        final totalLessons = courses.fold<int>(
          0,
          (sum, c) => sum + c.lessonCount,
        );
        final totalDuration = courses.fold<int>(
          0,
          (sum, c) => sum + c.durationMinutes,
        );

        return Right(DashboardStatsEntity(
          enrolledCourses: totalCourses,
          completedCourses: totalCourses,
          totalLessonsCompleted: totalLessons,
          totalMinutesLearned: totalDuration,
          overallProgress: totalCourses > 0 ? 100 : 0,
        ));
      }

      final enrolledCourses =
          courses.where((c) => c.isEnrolled).toList();
      final enrolledCount = enrolledCourses.length;
      final completedCount =
          enrolledCourses.where((c) => c.progress >= 100).length;

      int totalLessonsCompleted = 0;
      int totalMinutesLearned = 0;
      double totalProgress = 0;

      for (final course in enrolledCourses) {
        final progressFraction = (course.progress / 100).clamp(0.0, 1.0);
        totalLessonsCompleted += (course.lessonCount * progressFraction).round();
        totalMinutesLearned += (course.durationMinutes * progressFraction).round();
        totalProgress += course.progress;
      }

      final overallProgress =
          enrolledCount > 0 ? totalProgress / enrolledCount : 0.0;

      return Right(DashboardStatsEntity(
        enrolledCourses: enrolledCount,
        completedCourses: completedCount,
        totalLessonsCompleted: totalLessonsCompleted,
        totalMinutesLearned: totalMinutesLearned,
        overallProgress: overallProgress,
      ));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }
}
