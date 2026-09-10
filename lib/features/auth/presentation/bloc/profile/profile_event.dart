import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}
