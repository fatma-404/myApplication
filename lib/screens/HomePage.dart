import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'book_reader_screen.dart';
import 'upload_page.dart'; // Import the upload page
import '../models/book.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user
    final User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: const Center(child: Text('Please log in to see your books')),
      );
    }

// Reference to the books collection filtered by the user's UID
    final Query booksRef = FirebaseFirestore.instance
        .collection('books')
        .where('uploadedBy', isEqualTo: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to the upload page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadBookScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: booksRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Books Available'));
          }

          var books = snapshot.data!.docs.map((doc) => Book.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              var book = books[index];

              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.format),
                onTap: () {
                  // Navigate to the book reader screen, passing the selected book
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookReaderScreen(book: book),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
