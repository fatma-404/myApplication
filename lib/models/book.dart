import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String url;
  final String format;  // This indicates whether it's EPUB or PDF

  Book({required this.id, required this.title, required this.url, required this.format});

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      url: data['url'] ?? '',
      format: data['format'] ?? '',
    );
  }
}
