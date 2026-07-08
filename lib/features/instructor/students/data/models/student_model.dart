import 'package:lms/features/instructor/students/domain/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email,
    super.status,
    super.avatarUrl,
    super.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      status: _parseStatus(json['status'] as String?),
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  static StudentStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'invited':
        return StudentStatus.invited;
      case 'requested':
        return StudentStatus.requested;
      case 'active':
        return StudentStatus.active;
      case 'removed':
        return StudentStatus.removed;
      default:
        return StudentStatus.active;
    }
  }

  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      status: status,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
