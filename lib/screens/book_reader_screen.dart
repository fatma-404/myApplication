import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // For PDF rendering
import 'package:epub_view/epub_view.dart'; // For EPUB rendering
import 'package:http/http.dart' as http;
import '../models/book.dart'; // Import the Book model
import 'dart:io'; // For file handling
import 'package:path_provider/path_provider.dart'; // For getting local file directories

class BookReaderScreen extends StatefulWidget {
  final Book book;

  BookReaderScreen({required this.book});

  @override
  _BookReaderScreenState createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late EpubController _epubController;
  bool isEpub = false;
  String? pdfFilePath;
  bool isDarkMode = false; // Variable to manage theme state
  bool isDownloading = false; // Flag to indicate download in progress
  String? downloadError; // Store error message if download fails

  @override
  void initState() {
    super.initState();
    if (widget.book.format.toLowerCase() == 'epub') {
      print('Loading EPUB...');
      _initEpubController(widget.book.url);
    } else if (widget.book.format.toLowerCase() == 'pdf') {
      print('Loading PDF...');
      _downloadPdf(widget.book.url);
    } else {
      print('Unsupported book format: ${widget.book.format}');
    }

    print('Book format: ${widget.book.format}');

  }

  void _initEpubController(String epubUrl) async {
    try {
      setState(() {
        isDownloading = true;
      });
      final epubBytes = await _downloadEpub(epubUrl);
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/temp_book.epub';
      final file = File(filePath);
      await file.writeAsBytes(epubBytes);

      setState(() {
        isDownloading = false;
        isEpub = true;
        _epubController = EpubController(
          document: EpubDocument.openFile(file), // Pass File directly
        );
      });
    } catch (e) {
      setState(() {
        isDownloading = false;
        downloadError = 'Error downloading EPUB: $e';
        print(e);  // Log the error to see more details
      });
    }
  }


  Future<void> _downloadPdf(String pdfUrl) async {
    try {
      setState(() {
        isDownloading = true;
      });
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/temp_book.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          isDownloading = false;
          pdfFilePath = filePath;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
        downloadError = 'Error downloading PDF: $e';
      });
    }
  }

  Future<List<int>> _downloadEpub(String epubUrl) async {
    return http.get(Uri.parse(epubUrl))
        .then((response) {
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download EPUB: ${response.statusCode}');
      }
    })
        .catchError((error) {
      throw Exception('Error downloading EPUB: $error');
    });
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  void dispose() {
    // Check if _epubController is initialized before disposing
    _epubController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: isEpub
            ? [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme, // Toggle between light and dark mode
          ),
        ]
            : null,
      ),
      body: isDownloading
          ? Center(child: CircularProgressIndicator())
          : downloadError != null
          ? Center(child: Text(downloadError!))
          : isEpub
          ? Container(
        color: isDarkMode ? Colors.black : Colors.white, // Set background color based on theme
        child: EpubView(
          controller: _epubController,
          onDocumentLoaded: (document) {
            print('EPUB Document Loaded: ${document.Chapters?.length} chapters');
          },
          onDocumentError: (error) {
            print('EPUB Document Error: $error');
            setState(() {
              downloadError = 'Error loading EPUB: $error';
            });
          },
        ),
      )
          : (pdfFilePath != null
          ? PDFView(
        filePath: pdfFilePath,
        onRender: (_pages) {
          print('PDF Rendered with $_pages pages');
        },
        onError: (error) {
          print('PDF View Error: $error');
          setState(() {
            downloadError = 'Error loading PDF: $error';
          });
        },
        onPageError: (page, error) {
          print('Error on page $page: $error');
          setState(() {
            downloadError = 'Error on page $page: $error';
          });
        },
      )
          : Center(child: Text('Error loading PDF'))),
    );
  }
}