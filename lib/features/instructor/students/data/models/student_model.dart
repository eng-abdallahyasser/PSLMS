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
    final studentData = json['student'] as Map<String, dynamic>?;
    return StudentModel(
      id: json['id'] as String,
      firstName: (studentData?['firstName'] ?? studentData?['first_name'] ?? json['firstName'] ?? json['first_name'] ?? '') as String,
      lastName: (studentData?['lastName'] ?? studentData?['last_name'] ?? json['lastName'] ?? json['last_name'] ?? '') as String,
      email: (studentData?['email'] ?? json['email'] ?? json['invitedEmail']) as String?,
      status: _parseStatus(json['status'] as String?),
      avatarUrl: (studentData?['profileImageUrl'] ?? studentData?['avatarUrl'] ?? json['avatarUrl'] ?? json['avatar_url']) as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
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
