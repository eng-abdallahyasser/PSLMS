import 'package:equatable/equatable.dart';

class InstructorEntity extends Equatable {
  final String firstName;
  final String lastName;

  const InstructorEntity({
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [firstName, lastName];
}

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String visibility;
  final InstructorEntity? instructor;
  final String? thumbnailUrl;
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
    this.visibility = 'PUBLIC',
    this.instructor,
    this.thumbnailUrl,
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
    String? visibility,
    InstructorEntity? instructor,
    String? thumbnailUrl,
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
      visibility: visibility ?? this.visibility,
      instructor: instructor ?? this.instructor,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
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
        visibility,
        instructor,
        thumbnailUrl,
        lessonCount,
        durationMinutes,
        difficulty,
        progress,
        isEnrolled,
        createdAt,
      ];
}
