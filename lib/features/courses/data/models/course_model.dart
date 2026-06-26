import 'package:lms/features/courses/domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    super.thumbnailUrl,
    super.instructorName,
    super.lessonCount,
    super.durationMinutes,
    super.difficulty,
    super.progress,
    super.isEnrolled,
    super.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      instructorName: json['instructor_name'] as String?,
      lessonCount: json['lesson_count'] as int? ?? 0,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      isEnrolled: json['is_enrolled'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'instructor_name': instructorName,
      'lesson_count': lessonCount,
      'duration_minutes': durationMinutes,
      'difficulty': difficulty,
      'progress': progress,
      'is_enrolled': isEnrolled,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  CourseEntity toEntity() {
    return CourseEntity(
      id: id,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      instructorName: instructorName,
      lessonCount: lessonCount,
      durationMinutes: durationMinutes,
      difficulty: difficulty,
      progress: progress,
      isEnrolled: isEnrolled,
      createdAt: createdAt,
    );
  }

  factory CourseModel.fromEntity(CourseEntity entity) {
    return CourseModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      thumbnailUrl: entity.thumbnailUrl,
      instructorName: entity.instructorName,
      lessonCount: entity.lessonCount,
      durationMinutes: entity.durationMinutes,
      difficulty: entity.difficulty,
      progress: entity.progress,
      isEnrolled: entity.isEnrolled,
      createdAt: entity.createdAt,
    );
  }
}
