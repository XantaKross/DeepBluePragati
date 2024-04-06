import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'API.dart';

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
              icon: Icon(Icons.arrow_back_ios_new_sharp)),
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
  late PdfViewerController _pdfViewerController;
  late String _base64EncodedData;
  File? _localFile;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    if (kIsWeb) {
      // Load PDF from base64 encoded data for web
      _loadPDFFromBase64();
    } else {
      // Load PDF from local file for Android
      _loadPDFFromLocalFile();
    }
  }

  void _loadPDFFromBase64() {
    // Assuming base64EncodedData is available from API.webUploadedFile
    Uint8List? data = API.webUploadedFile;
    if (data != null) {
      _base64EncodedData = base64Encode(data);
      setState(() {
        // Update your UI with the base64 encoded data
      });
    }
  }

  _loadPDFFromLocalFile() {
    // Assuming path is available from the local file
    final String path = API.uploadedFile?.path ?? '';
    if (path.isNotEmpty) {
      _localFile = File(path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _base64EncodedData.isNotEmpty
          ? SfPdfViewer.memory(
              Uint8List.fromList(base64Decode(_base64EncodedData)),
              controller: _pdfViewerController,
            )
          : Center(child: CircularProgressIndicator());
    } else {
      return _localFile != null
          ? SfPdfViewer.file(
              _localFile!,
              controller: _pdfViewerController,
            )
          : Center(child: CircularProgressIndicator());
    }
  }
}
