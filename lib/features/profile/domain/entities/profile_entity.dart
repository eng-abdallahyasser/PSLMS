import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final DateTime? joinedAt;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.joinedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        bio,
        joinedAt,
      ];
}
