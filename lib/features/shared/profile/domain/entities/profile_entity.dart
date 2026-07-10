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
    this.createdAt,
  });
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? avatarUrl;
  final String lang;
  final String mode;
  final DateTime? createdAt;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';

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
        createdAt,
      ];
}
