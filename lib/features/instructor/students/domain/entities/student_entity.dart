import 'package:equatable/equatable.dart';

enum StudentStatus { invited, requested, active, removed }

class StudentEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final StudentStatus status;
  final String? avatarUrl;
  final DateTime? createdAt;

  const StudentEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.status = StudentStatus.active,
    this.avatarUrl,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName, email, status, avatarUrl, createdAt];
}
