import 'package:lms/features/instructors/domain/entities/invitation_info_entity.dart';

class InvitationInfoModel extends InvitationInfoEntity {
  const InvitationInfoModel({
    required super.instructorName,
    super.instructorEmail,
    super.message,
    super.isExpired,
  });

  factory InvitationInfoModel.fromJson(Map<String, dynamic> json) {
    return InvitationInfoModel(
      instructorName: json['instructorName'] as String? ??
          json['instructor_name'] as String? ??
          '',
      instructorEmail: json['instructorEmail'] as String? ??
          json['instructor_email'] as String?,
      message: json['message'] as String?,
      isExpired: json['isExpired'] as bool? ??
          json['is_expired'] as bool? ??
          false,
    );
  }

  InvitationInfoEntity toEntity() {
    return InvitationInfoEntity(
      instructorName: instructorName,
      instructorEmail: instructorEmail,
      message: message,
      isExpired: isExpired,
    );
  }
}
