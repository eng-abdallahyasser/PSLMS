import 'package:equatable/equatable.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';

class ProfileEntity extends Equatable {

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role = UserRole.learner,
    this.avatarUrl,
    this.lang = 'en',
    this.mode = 'light',
    this.mobileNumber,
    this.isMobileVerified = false,
    this.isEmailVerified = false,
    this.isActive = true,
    this.universityId,
    this.faculty,
    this.department,
    this.year,
    this.storageQuotaBytes = 0,
    this.createdAt,
    this.updatedAt,
  });
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? avatarUrl;
  final String lang;
  final String mode;
  final String? mobileNumber;
  final bool isMobileVerified;
  final bool isEmailVerified;
  final bool isActive;
  final String? universityId;
  final String? faculty;
  final String? department;
  final String? year;
  final int storageQuotaBytes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';

  /// Human-readable storage quota, e.g. `5368709120` → `5 GB`.
  String get storageQuotaLabel {
    if (storageQuotaBytes <= 0) return '—';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = storageQuotaBytes.toDouble();
    var i = 0;
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    var text = size.toStringAsFixed(1);
    if (text.endsWith('.0')) text = text.substring(0, text.length - 2);
    return '$text ${units[i]}';
  }

  ProfileEntity copyWith({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? lang,
    String? mode,
    String? mobileNumber,
    bool? isMobileVerified,
    bool? isEmailVerified,
    bool? isActive,
    String? universityId,
    String? faculty,
    String? department,
    String? year,
    int? storageQuotaBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lang: lang ?? this.lang,
      mode: mode ?? this.mode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isMobileVerified: isMobileVerified ?? this.isMobileVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      universityId: universityId ?? this.universityId,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      year: year ?? this.year,
      storageQuotaBytes: storageQuotaBytes ?? this.storageQuotaBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        role,
        avatarUrl,
        lang,
        mode,
        mobileNumber,
        isMobileVerified,
        isEmailVerified,
        isActive,
        universityId,
        faculty,
        department,
        year,
        storageQuotaBytes,
        createdAt,
        updatedAt,
      ];
}
