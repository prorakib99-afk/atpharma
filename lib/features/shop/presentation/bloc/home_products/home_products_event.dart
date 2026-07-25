import 'package:equatable/equatable.dart';

sealed class HomeProductsEvent extends Equatable {
  const HomeProductsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// প্রথমবার Home screen open হলে call হবে।
final class HomeProductsStarted extends HomeProductsEvent {
  const HomeProductsStarted();
}

/// Pull-to-refresh অথবা manual refresh।
final class HomeProductsRefreshed extends HomeProductsEvent {
  const HomeProductsRefreshed();
}

/// নির্দিষ্ট product page load করবে।
final class HomeProductsPageRequested extends HomeProductsEvent {
  const HomeProductsPageRequested({required this.page, this.force = false});

  final int page;

  /// true হলে cached/current page হলেও নতুন করে load করবে।
  final bool force;

  @override
  List<Object?> get props => <Object?>[page, force];
}

/// পরবর্তী page।
final class HomeProductsNextPageRequested extends HomeProductsEvent {
  const HomeProductsNextPageRequested();
}

/// আগের page।
final class HomeProductsPreviousPageRequested extends HomeProductsEvent {
  const HomeProductsPreviousPageRequested();
}

/// Current products page retry।
final class HomeProductsRetryRequested extends HomeProductsEvent {
  const HomeProductsRetryRequested();
}

/// Featured products retry।
final class HomeFeaturedProductsRetryRequested extends HomeProductsEvent {
  const HomeFeaturedProductsRetryRequested();
}
