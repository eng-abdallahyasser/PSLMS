class PageMeta {
  const PageMeta({
    this.itemsPerPage = 20,
    this.totalItems = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  final int itemsPerPage;
  final int totalItems;
  final int currentPage;
  final int totalPages;

  factory PageMeta.fromJson(Map<String, dynamic> json) {
    return PageMeta(
      itemsPerPage: json['itemsPerPage'] as int? ?? 20,
      totalItems: json['totalItems'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  PageMeta copyWith({
    int? itemsPerPage,
    int? totalItems,
    int? currentPage,
    int? totalPages,
  }) {
    return PageMeta(
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class PaginatedResult<T> {
  const PaginatedResult({required this.items, required this.meta});

  final List<T> items;
  final PageMeta meta;

  bool get hasNextPage => currentPage < totalPages;
  int get currentPage => meta.currentPage;
  int get totalPages => meta.totalPages;
  int get totalItems => meta.totalItems;
}
