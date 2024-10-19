import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart'; // For using basename
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epubx/epubx.dart'; // Import the epubx package for EPUB metadata

class UploadService {

  // This method uploads a book and extracts its title if available
  Future<String> uploadBook(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = basename(filePath); // Get the file name from the path
      final storageRef = FirebaseStorage.instance.ref().child('books/$fileName');
      print("Firebase Storage path: books/$fileName");

      // Get the current user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User not logged in");
        return 'no_user';  // User is not logged in
      }
      print("User UID: ${user.uid}");


      // Extract book title from EPUB file if possible
      String bookTitle = fileName;  // Default title as file name
      if (filePath.endsWith('.epub')) {
        try {
          print("Attempting to read EPUB metadata");
          EpubBook epubBook = await EpubReader.readBook(file.readAsBytesSync());
          bookTitle = epubBook.Title ?? fileName;
          print("EPUB Title: $bookTitle");
        } catch (e) {
          print('Failed to read EPUB metadata: $e');
        }
      }

      // Check if the file already exists in Firebase Storage
      final listResult = await FirebaseStorage.instance.ref('books').listAll();
      final existingFile = listResult.items.any((item) => item.name == fileName);

      if (existingFile) {
        return 'file_exists';  // File already exists
      } else {
        // Upload the file to Firebase Storage
        final uploadTask = await storageRef.putFile(file);
        final fileUrl = await storageRef.getDownloadURL(); // Get the file's download URL

        // Store the book information in Firestore
        await FirebaseFirestore.instance.collection('books').add({
          'title': bookTitle,           // Use the extracted or fallback title
          'fileUrl': fileUrl,           // Store the download URL
          'uploadedBy': user.uid,       // Store the UID of the user
          'uploadedAt': Timestamp.now(),  // Store the timestamp
        });

        return 'success';  // Upload success
      }
    } catch (error) {
      print('Upload failed: $error');
      return 'Upload failed with error: $error';  // Detailed error message
    }
  }

  // File picking function to let the user select a book
  Future<String?> pickAndUploadBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String filePath = result.files.single.path!;
      print("Selected file path: $filePath");

      return await uploadBook(filePath);
    } else {
      return 'no_file';  // No file selected
    }
  }
}
