import 'package:lms/features/shared/domain/entities/course_entity.dart';

class InstructorModel extends InstructorEntity {
  const InstructorModel({
    required super.firstName,
    required super.lastName,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  InstructorEntity toEntity() {
    return InstructorEntity(firstName: firstName, lastName: lastName);
  }
}

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    super.visibility,
    super.instructor,
    super.thumbnailUrl,
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
      visibility: json['visibility'] as String? ?? 'PUBLIC',
      instructor: json['instructor'] != null
          ? InstructorModel.fromJson(json['instructor'] as Map<String, dynamic>)
          : null,
      thumbnailUrl: json['thumbnail_url'] as String? ?? json['thumbnailUrl'] as String?,
      lessonCount: json['lesson_count'] as int? ?? json['lessonCount'] as int? ?? 0,
      durationMinutes: json['duration_minutes'] as int? ?? json['durationMinutes'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      isEnrolled: json['is_enrolled'] as bool? ?? json['isEnrolled'] as bool? ?? false,
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
      'visibility': visibility,
      'instructor': (instructor is InstructorModel
          ? (instructor as InstructorModel).toJson()
          : instructor != null
              ? InstructorModel(firstName: instructor!.firstName, lastName: instructor!.lastName).toJson()
              : null),
      'thumbnail_url': thumbnailUrl,
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
      visibility: visibility,
      instructor: instructor != null
          ? InstructorEntity(firstName: instructor!.firstName, lastName: instructor!.lastName)
          : null,
      thumbnailUrl: thumbnailUrl,
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
      visibility: entity.visibility,
      instructor: entity.instructor != null
          ? InstructorModel(firstName: entity.instructor!.firstName, lastName: entity.instructor!.lastName)
          : null,
      thumbnailUrl: entity.thumbnailUrl,
      lessonCount: entity.lessonCount,
      durationMinutes: entity.durationMinutes,
      difficulty: entity.difficulty,
      progress: entity.progress,
      isEnrolled: entity.isEnrolled,
      createdAt: entity.createdAt,
    );
  }
}
