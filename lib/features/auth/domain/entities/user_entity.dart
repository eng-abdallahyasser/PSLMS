import 'package:equatable/equatable.dart';

enum UserRole {
  learner,
  instructor,
  admin;

  String get value {
    switch (this) {
      case UserRole.learner:
        return 'learner';
      case UserRole.instructor:
        return 'instructor';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LEARNER':
        return UserRole.learner;
      case 'INSTRUCTOR':
        return UserRole.instructor;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.learner;
    }
  }
}

class UserEntity extends Equatable {

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role = UserRole.learner,
    this.avatarUrl,
    this.createdAt,
  });
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? avatarUrl;
  final DateTime? createdAt;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        role,
        avatarUrl,
        createdAt,
      ];
}
