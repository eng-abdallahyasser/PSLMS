import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/core/utils/avatar_url.dart';
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
      mobileNumber: entity.mobileNumber,
      isMobileVerified: entity.isMobileVerified,
      isEmailVerified: entity.isEmailVerified,
      isActive: entity.isActive,
      universityId: entity.universityId,
      faculty: entity.faculty,
      department: entity.department,
      year: entity.year,
      storageQuotaBytes: entity.storageQuotaBytes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
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
    super.mobileNumber,
    super.isMobileVerified,
    super.isEmailVerified,
    super.isActive,
    super.universityId,
    super.faculty,
    super.department,
    super.year,
    super.storageQuotaBytes,
    super.createdAt,
    super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Preferences arrive nested: `preferences: {lang, mode}` (top-level
    // fallback kept for older payloads).
    final prefs = json['preferences'];
    final prefsMap = prefs is Map<String, dynamic> ? prefs : null;
    return ProfileModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      role: json['role'] != null
          ? UserRole.fromString(json['role'] as String)
          : UserRole.learner,
      avatarUrl: AvatarUrl.resolve(
        json['profileImageUrl'] as String? ??
            json['profile_image_url'] as String? ??
            json['avatar_url'] as String? ??
            json['avatarUrl'] as String?,
      ),
      lang: prefsMap?['lang'] as String? ?? json['lang'] as String? ?? 'en',
      mode: prefsMap?['mode'] as String? ?? json['mode'] as String? ?? 'light',
      mobileNumber: json['mobileNumber'] as String? ??
          json['mobile_number'] as String?,
      isMobileVerified: json['isMobileVerified'] as bool? ??
          json['is_mobile_verified'] as bool? ??
          false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      universityId: json['universityId'] as String?,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      year: json['year'] as String?,
      storageQuotaBytes:
          num.tryParse(json['storageQuotaBytes']?.toString() ?? '')?.toInt() ??
              0,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role.value,
      'profileImageUrl': avatarUrl,
      'preferences': {'lang': lang, 'mode': mode},
      'mobileNumber': mobileNumber,
      'isMobileVerified': isMobileVerified,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'universityId': universityId,
      'faculty': faculty,
      'department': department,
      'year': year,
      'storageQuotaBytes': '$storageQuotaBytes',
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
      mobileNumber: mobileNumber,
      isMobileVerified: isMobileVerified,
      isEmailVerified: isEmailVerified,
      isActive: isActive,
      universityId: universityId,
      faculty: faculty,
      department: department,
      year: year,
      storageQuotaBytes: storageQuotaBytes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
