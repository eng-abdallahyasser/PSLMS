import 'package:lms/features/enrollments/domain/entities/enrollment_entity.dart';

class EnrollmentModel extends EnrollmentEntity {
  const EnrollmentModel({
    required super.id,
    required super.status,
    required super.courseId,
    required super.learnerId,
    super.learnerFirstName,
    super.learnerEmail,
    super.createdAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    // Handle learner info nested inside a learner object
    String? learnerFirstName;
    String? learnerEmail;
    if (json['learner'] != null) {
      final learner = json['learner'] as Map<String, dynamic>;
      learnerFirstName = learner['firstName'] as String?;
      learnerEmail = learner['email'] as String?;
    }

    return EnrollmentModel(
      id: json['id'] as String,
      status: json['status'] != null
          ? EnrollmentStatus.fromString(json['status'] as String)
          : EnrollmentStatus.pending,
      courseId: json['courseId'] as String? ?? json['course_id'] as String? ?? '',
      learnerId: json['learnerId'] as String? ?? json['learner_id'] as String? ?? '',
      learnerFirstName: learnerFirstName,
      learnerEmail: learnerEmail,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.value,
      'courseId': courseId,
      'learnerId': learnerId,
      if (learnerEmail != null)
        'learner': {
          'firstName': learnerFirstName,
          'email': learnerEmail,
        },
      'created_at': createdAt?.toIso8601String(),
    };
  }

  EnrollmentEntity toEntity() {
    return EnrollmentEntity(
      id: id,
      status: status,
      courseId: courseId,
      learnerId: learnerId,
      learnerFirstName: learnerFirstName,
      learnerEmail: learnerEmail,
      createdAt: createdAt,
    );
  }

  factory EnrollmentModel.fromEntity(EnrollmentEntity entity) {
    return EnrollmentModel(
      id: entity.id,
      status: entity.status,
      courseId: entity.courseId,
      learnerId: entity.learnerId,
      learnerFirstName: entity.learnerFirstName,
      learnerEmail: entity.learnerEmail,
      createdAt: entity.createdAt,
    );
  }
}
