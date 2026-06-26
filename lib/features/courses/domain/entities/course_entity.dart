import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String? instructorName;
  final int lessonCount;
  final int durationMinutes;
  final String difficulty;
  final double progress;
  final bool isEnrolled;
  final DateTime? createdAt;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    this.instructorName,
    this.lessonCount = 0,
    this.durationMinutes = 0,
    this.difficulty = 'beginner',
    this.progress = 0,
    this.isEnrolled = false,
    this.createdAt,
  });

  CourseEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? instructorName,
    int? lessonCount,
    int? durationMinutes,
    String? difficulty,
    double? progress,
    bool? isEnrolled,
    DateTime? createdAt,
  }) {
    return CourseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      instructorName: instructorName ?? this.instructorName,
      lessonCount: lessonCount ?? this.lessonCount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      progress: progress ?? this.progress,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnailUrl,
        instructorName,
        lessonCount,
        durationMinutes,
        difficulty,
        progress,
        isEnrolled,
        createdAt,
      ];
}
