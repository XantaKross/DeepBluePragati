import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'API.dart';
import 'upload_page.dart';



class PDFViewerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('PDF Viewer'),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new_sharp),
          ),
        ),
        body: PDFViewerWidget(),
      ),
    );
  }
}

class PDFViewerWidget extends StatefulWidget {
  @override
  _PDFViewerWidgetState createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget> {
  late PdfViewerController pdfViewerController;
  late Future<dynamic> _pdfFuture;
  bool change = true;


  @override
  void initState() {
    super.initState();
    pdfViewerController = PdfViewerController();
    _pdfFuture = _loadPDF();
  }

  Future<dynamic> _loadPDF() async {
    if (api.isUpdated) {
      await api.getLatestFile();
      api.isUpdated = false; // Reset the flag after updating
    }

    if (kIsWeb) {
      // Load PDF from base64 encoded data for web
      Uint8List? data = ChatAPI.webUploadedFile;
      if (data != null) {
        return base64Encode(data);
      }
    } else {
      // Load PDF from local file for Android
      final File? file = ChatAPI.uploadedFile;
      if (file != null && file.path.isNotEmpty) {
        return file;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _pdfFuture,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingOverlay();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data;
          if (kIsWeb) {
            if (data is String) {
              return SfPdfViewer.memory(
                Uint8List.fromList(base64Decode(data)),
                controller: pdfViewerController,
              );
            }
          } else {
            if (data is File) {
              return SfPdfViewer.file(
                data,
                controller: pdfViewerController,
              );
            }
          }
        }
        return Center(child: Text('No PDF available'));
      },

    );
  }
}