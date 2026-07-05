import 'package:lms/features/instructors/domain/entities/instructor_profile_entity.dart';

class InstructorProfileModel extends InstructorProfileEntity {
  const InstructorProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email,
    super.bio,
    super.avatarUrl,
    super.courseCount,
    super.studentCount,
    super.specialization,
  });

  factory InstructorProfileModel.fromJson(Map<String, dynamic> json) {
    return InstructorProfileModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      courseCount: (json['courseCount'] as num?)?.toInt() ??
          (json['course_count'] as num?)?.toInt(),
      studentCount: (json['studentCount'] as num?)?.toInt() ??
          (json['student_count'] as num?)?.toInt(),
      specialization: json['specialization'] as String?,
    );
  }

  InstructorProfileEntity toEntity() {
    return InstructorProfileEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      bio: bio,
      avatarUrl: avatarUrl,
      courseCount: courseCount,
      studentCount: studentCount,
      specialization: specialization,
    );
  }
}
