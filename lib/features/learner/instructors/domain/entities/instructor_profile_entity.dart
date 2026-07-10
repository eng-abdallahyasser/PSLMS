import 'package:equatable/equatable.dart';

class InstructorProfileEntity extends Equatable {

  const InstructorProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.mobileNumber,
    this.createdAt,
    this.bio,
    this.avatarUrl,
    this.courseCount,
    this.studentCount,
    this.specialization,
  });
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? mobileNumber;
  final DateTime? createdAt;
  final String? bio;
  final String? avatarUrl;
  final int? courseCount;
  final int? studentCount;
  final String? specialization;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        mobileNumber,
        createdAt,
        bio,
        avatarUrl,
        courseCount,
        studentCount,
        specialization,
      ];
}
