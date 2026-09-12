import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

final class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({required this.name, required this.phone});

  final String name;
  final String phone;

  @override
  List<Object?> get props => <Object?>[name, phone];
}
