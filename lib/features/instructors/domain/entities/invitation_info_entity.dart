import 'package:equatable/equatable.dart';

class InvitationInfoEntity extends Equatable {
  final String instructorName;
  final String? instructorEmail;
  final String? message;
  final bool isExpired;

  const InvitationInfoEntity({
    required this.instructorName,
    this.instructorEmail,
    this.message,
    this.isExpired = false,
  });

  @override
  List<Object?> get props => [
        instructorName,
        instructorEmail,
        message,
        isExpired,
      ];
}
