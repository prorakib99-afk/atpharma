import 'package:equatable/equatable.dart';

import '../../domain/entities/my_review_entity.dart';

enum MyReviewsStatus { initial, loading, success, failure }

final class MyReviewsState extends Equatable {
  const MyReviewsState({
    this.status = MyReviewsStatus.initial,
    this.reviews = const <MyReviewEntity>[],
    this.deletingReviewId,
    this.message,
  });

  final MyReviewsStatus status;
  final List<MyReviewEntity> reviews;
  final String? deletingReviewId;
  final String? message;

  MyReviewsState copyWith({
    MyReviewsStatus? status,
    List<MyReviewEntity>? reviews,
    String? deletingReviewId,
    bool clearDeletingReviewId = false,
    String? message,
    bool clearMessage = false,
  }) {
    return MyReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      deletingReviewId: clearDeletingReviewId
          ? null
          : deletingReviewId ?? this.deletingReviewId,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    reviews,
    deletingReviewId,
    message,
  ];
}
