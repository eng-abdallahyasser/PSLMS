import 'package:equatable/equatable.dart';

class InstructorProfileEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? bio;
  final String? avatarUrl;
  final int? courseCount;
  final int? studentCount;
  final String? specialization;

  const InstructorProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.bio,
    this.avatarUrl,
    this.courseCount,
    this.studentCount,
    this.specialization,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        bio,
        avatarUrl,
        courseCount,
        studentCount,
        specialization,
      ];
}
