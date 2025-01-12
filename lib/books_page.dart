import 'package:flutter/material.dart';
import 'package:books_app/book.dart';
import 'package:books_app/book_database.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final textTitleController = TextEditingController();
  final textAuthorController = TextEditingController();
  final textDateController = TextEditingController();
  final textAvailableController = TextEditingController();
  final _bookDatabase = BookDatabase();

  String searchQuery = "";
  bool isFilteredByAvailable = false;
  bool isAvailableNewBook = false;
  bool isAvailableEditBook = false;
  bool isFilteredbyAuthor = false;

  // Build halamam UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update query pencarian
                });
              },
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _bookDatabase.getBooksStream(),
        builder: (context, snapshot) {
          // loading ...
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // loaded
          final books = snapshot.data!;

          // Filter buku berdasarkan query pencarian
          final searchedBooks = books
              .where((book) =>
                  book.title.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return ListView.builder(
            itemCount: searchedBooks.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(searchedBooks[index].title),
              subtitle: Text(searchedBooks[index].author),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => editBook(searchedBooks[index]),
                      icon: const Icon(Icons.edit, color: Colors.green),
                    ),
                    IconButton(
                      onPressed: () => deleteBook(searchedBooks[index]),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBook,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNewBook() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textTitleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: textAuthorController,
              decoration: const InputDecoration(hintText: 'Author'),
            ),
            TextField(
              controller: textDateController,
              decoration: const InputDecoration(
                  hintText: 'Published Date (yyyy-mm-dd)'),
            ),
            Row(
              children: [
                const Text('Mark as Available:'),
                Checkbox(
                  value: isAvailableNewBook,
                  onChanged: (value) {
                    setState(() {
                      isAvailableNewBook = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final book = Book(
                title: textTitleController.text,
                author: textAuthorController.text,
                publishedDate: DateTime.parse(textDateController.text),
                isAvailable: isAvailableNewBook,
              );

              _bookDatabase.insertBook(book);
              Navigator.pop(context);
              textTitleController.clear();
              setState(() {
                isAvailableNewBook = false;
              });
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  // Edit buku
  void editBook(Book book) {
    textTitleController.text = book.title;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textTitleController,
              decoration: const InputDecoration(
                hintText: 'Enter Book Title',
              ),
            ),
            Row(
              children: [
                const Text('Mark as Available:'),
                Checkbox(
                  value: isAvailableEditBook,
                  onChanged: (value) {
                    setState(() {
                      isAvailableEditBook = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              book.title = textTitleController.text;
              book.isAvailable = isAvailableEditBook; // Update judul buku
              _bookDatabase.updateBookAvailability(
                  book.id!, book.isAvailable); // Update buku di database

              Navigator.pop(context);
              textTitleController.clear();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              textTitleController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Hapus Buku
  void deleteBook(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content:
                      Text('This action cannot be undone.\n\n"${book.title}"'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _bookDatabase.deleteBook(book.id!);
                        Navigator.pop(context);
                      },
                      child: const Text('Yes, Delete'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
