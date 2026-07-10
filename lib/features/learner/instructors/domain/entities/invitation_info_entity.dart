import 'package:equatable/equatable.dart';

class InvitationInfoEntity extends Equatable {

  const InvitationInfoEntity({
    required this.instructorName,
    this.instructorEmail,
    this.message,
    this.isExpired = false,
  });
  final String instructorName;
  final String? instructorEmail;
  final String? message;
  final bool isExpired;

  @override
  List<Object?> get props => [
        instructorName,
        instructorEmail,
        message,
        isExpired,
      ];
}
