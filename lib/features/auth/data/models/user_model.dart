import 'package:lms/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      role: entity.role,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
    );
  }
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.role,
    super.avatarUrl,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      role: json['role'] != null
          ? UserRole.fromString(json['role'] as String)
          : UserRole.learner,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.value,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
