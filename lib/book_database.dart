import 'package:books_app/book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookDatabase {
  final database = Supabase.instance.client.from('books');

  // Insert a book
  Future<void> insertBook(Book book) async {
    await database.insert(book.toJson());
  }

  // Get a stream of books
  Stream<List<Book>> getBooksStream() {
    return database.stream(primaryKey: ['id']).map(
        (data) => data.map((json) => Book.fromJson(json)).toList());
  }

  // Delete a book
  Future<void> deleteBook(int id) async {
    await database.delete().eq('id', id);
  }

  // Update a book's availability
  Future<void> updateBookAvailability(int id, bool isAvailable) async {
    await database.update({'is_available': isAvailable}).eq('id', id);
  }
}
