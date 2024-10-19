import 'package:flutter/material.dart';
import '../services/upload_service.dart'; // Import your service file

class UploadBookScreen extends StatelessWidget {
  final UploadService uploadService = UploadService(); // Create an instance of the service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Book'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Call the upload function and handle the result
            String? result = await uploadService.pickAndUploadBook();

            if (result == 'success') {
              showUploadResult(context, true, 'Book uploaded successfully!');
            } else if (result == 'failure') {
              showUploadResult(context, false, 'Failed to upload book.');
            } else if (result == 'file_exists') {
              showUploadResult(context, false, 'A file with this name already exists.');
            } else if (result == 'no_file') {
              showUploadResult(context, false, 'No file selected.');
            }
          },
          child: Text('Upload Book'),
        ),
      ),
    );
  }

  // Function to show the dialog based on result
  void showUploadResult(BuildContext context, bool success, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Success' : 'Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
