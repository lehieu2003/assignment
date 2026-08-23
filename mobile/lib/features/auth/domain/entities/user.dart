import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String? fullName;
  final bool isActive;
  final bool isSuperuser;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    required this.isActive,
    required this.isSuperuser,
  });

  @override
  List<Object?> get props => [id, email, fullName, isActive, isSuperuser];
}
