import 'package:equatable/equatable.dart';

final class PaginatedResult<T> extends Equatable {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  }) : assert(page >= 1, 'Page must be at least 1.'),
       assert(perPage > 0, 'Per-page value must be greater than 0.'),
       assert(total >= 0, 'Total cannot be negative.'),
       assert(totalPages >= 0, 'Total pages cannot be negative.');

  final List<T> items;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool get isFirstPage => page <= 1;

  bool get isLastPage {
    return totalPages == 0 || page >= totalPages;
  }

  bool get hasPreviousPage => page > 1;

  bool get hasNextPage {
    return totalPages > 0 && page < totalPages;
  }

  int? get previousPage {
    return hasPreviousPage ? page - 1 : null;
  }

  int? get nextPage {
    return hasNextPage ? page + 1 : null;
  }

  int get loadedItemCount => items.length;

  PaginatedResult<T> copyWith({
    List<T>? items,
    int? page,
    int? perPage,
    int? total,
    int? totalPages,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  PaginatedResult<T> append(
    PaginatedResult<T> nextResult, {
    Object? Function(T item)? idSelector,
  }) {
    if (items.isEmpty) {
      return PaginatedResult<T>(
        items: List<T>.unmodifiable(nextResult.items),
        page: nextResult.page,
        perPage: nextResult.perPage,
        total: nextResult.total,
        totalPages: nextResult.totalPages,
      );
    }

    if (nextResult.items.isEmpty) {
      return copyWith(
        page: nextResult.page,
        perPage: nextResult.perPage,
        total: nextResult.total,
        totalPages: nextResult.totalPages,
      );
    }

    if (idSelector == null) {
      return PaginatedResult<T>(
        items: List<T>.unmodifiable(<T>[...items, ...nextResult.items]),
        page: nextResult.page,
        perPage: nextResult.perPage,
        total: nextResult.total,
        totalPages: nextResult.totalPages,
      );
    }

    final Map<Object?, T> uniqueItems = <Object?, T>{};

    for (final T item in items) {
      uniqueItems[idSelector(item)] = item;
    }

    for (final T item in nextResult.items) {
      uniqueItems[idSelector(item)] = item;
    }

    return PaginatedResult<T>(
      items: List<T>.unmodifiable(uniqueItems.values),
      page: nextResult.page,
      perPage: nextResult.perPage,
      total: nextResult.total,
      totalPages: nextResult.totalPages,
    );
  }

  static PaginatedResult<E> empty<E>({int page = 1, int perPage = 10}) {
    return PaginatedResult<E>(
      items: List<E>.empty(growable: false),
      page: page,
      perPage: perPage,
      total: 0,
      totalPages: 0,
    );
  }

  @override
  List<Object?> get props => <Object?>[items, page, perPage, total, totalPages];
}
