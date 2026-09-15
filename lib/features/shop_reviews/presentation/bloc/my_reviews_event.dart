import 'package:equatable/equatable.dart';

sealed class MyReviewsEvent extends Equatable {
  const MyReviewsEvent();
  @override
  List<Object?> get props => <Object?>[];
}

final class MyReviewsRequested extends MyReviewsEvent {
  const MyReviewsRequested({this.refresh = false});
  final bool refresh;
  @override
  List<Object?> get props => <Object?>[refresh];
}

final class MyReviewDeleteRequested extends MyReviewsEvent {
  const MyReviewDeleteRequested({required this.reviewId});
  final String reviewId;
  @override
  List<Object?> get props => <Object?>[reviewId];
}
