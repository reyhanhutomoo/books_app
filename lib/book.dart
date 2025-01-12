class Book {
  final int? id;
  String title;
  String author;
  DateTime publishedDate;
  bool isAvailable;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.publishedDate,
    required this.isAvailable,
  });

  // Convert JSON to Book object
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      publishedDate: DateTime.parse(json['published_date'] as String),
      isAvailable: json['is_available'] ?? false,
    );
  }

  // Convert Book object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'published_date': publishedDate.toIso8601String(),
      'is_available': isAvailable,
    };
  }
}
