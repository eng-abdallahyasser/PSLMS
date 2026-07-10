import 'package:equatable/equatable.dart';

enum EnrollmentStatus {
  pending,
  approved,
  rejected;

  String get value {
    switch (this) {
      case EnrollmentStatus.pending:
        return 'PENDING';
      case EnrollmentStatus.approved:
        return 'APPROVED';
      case EnrollmentStatus.rejected:
        return 'REJECTED';
    }
  }

  static EnrollmentStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return EnrollmentStatus.pending;
      case 'APPROVED':
        return EnrollmentStatus.approved;
      case 'REJECTED':
        return EnrollmentStatus.rejected;
      default:
        return EnrollmentStatus.pending;
    }
  }
}

class EnrollmentEntity extends Equatable {

  const EnrollmentEntity({
    required this.id,
    required this.status,
    required this.courseId,
    required this.learnerId,
    this.learnerFirstName,
    this.learnerEmail,
    this.createdAt,
  });
  final String id;
  final EnrollmentStatus status;
  final String courseId;
  final String learnerId;
  final String? learnerFirstName;
  final String? learnerEmail;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        status,
        courseId,
        learnerId,
        learnerFirstName,
        learnerEmail,
        createdAt,
      ];
}
