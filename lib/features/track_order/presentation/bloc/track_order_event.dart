import 'package:equatable/equatable.dart';

sealed class TrackOrderEvent extends Equatable {
  const TrackOrderEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class TrackOrderSubmitted extends TrackOrderEvent {
  const TrackOrderSubmitted({required this.code});

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}

final class TrackOrderReset extends TrackOrderEvent {
  const TrackOrderReset();
}
