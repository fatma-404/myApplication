import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addBook(String title, String downloadUrl, String format) async {
    await _firestore.collection('books').add({
      'title': title,
      'url': downloadUrl,
      'format': format,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getBooks() {
    return _firestore.collection('books').orderBy('createdAt').snapshots();
  }
}
