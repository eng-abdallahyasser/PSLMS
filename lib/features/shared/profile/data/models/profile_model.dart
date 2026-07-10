import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/shared/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      role: entity.role,
      avatarUrl: entity.avatarUrl,
      lang: entity.lang,
      mode: entity.mode,
      createdAt: entity.createdAt,
    );
  }
  const ProfileModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.role,
    super.avatarUrl,
    super.lang,
    super.mode,
    super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      role: json['role'] != null
          ? UserRole.fromString(json['role'] as String)
          : UserRole.learner,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      lang: json['lang'] as String? ?? 'en',
      mode: json['mode'] as String? ?? 'light',
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
      'lang': lang,
      'mode': mode,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      avatarUrl: avatarUrl,
      lang: lang,
      mode: mode,
      createdAt: createdAt,
    );
  }
}
