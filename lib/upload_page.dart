// ignore_for_file: unused_import, override_on_non_overriding_member, no_leading_underscores_for_local_identifiers, unused_local_variable, prefer_const_constructors, unused_element, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'API.dart';
import 'Chatbot.dart';

Color _gold = Color(0xFFD4A064);
Color _white = Color(0xFFF2F5F8);
Color _blue = Color(0xFF1C2541);
Color _red = Color(0xFFCC4E5C);

ChatAPI api = new ChatAPI();

Future<void> fetchFiles() async {
  await api.getFiles();
}


void changeMainFile(BuildContext context) async {
  final overlayState = Overlay.of(context);

  // Create the loading overlay entry
  final overlayEntry = OverlayEntry(
    builder: (BuildContext context) => const LoadingOverlay(),
  );

  // Insert the overlay entry
  overlayState.insert(overlayEntry);

  try {
    await api.changeMainFile();
  } catch (error) {// Handle errors gracefully
    print(error);}
  finally {// Hide the loading animation regardless of success or failure
    overlayEntry.remove(); }

}


class Myupload extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        // Add your theme configurations here
      ),
      home: UploadPage(),
    );
  }
}

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String _fileName = '';
  List<String> _uploadedFileNames = [];
  bool changes = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    api.getFiles(); // Get files list. As soon as this page is reached.
    }




  File? uploadedFile; // Declare the variable outside the function
  Future pickFile() async {
    FilePickerResult? result =
    await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      if (mounted) {
        setState(() {
          _fileName = result.files.single.name;
          _uploadedFileNames.add(_fileName);

          api.isUpdated = true;

          if (kIsWeb) {
            final data = result.files.single.bytes;
            ChatAPI.webUploadedFile = data as Uint8List;

            api.sendFile(data, _fileName, kIsWeb);

          } else {
            final path = result.files.first.path;
            SfPdfViewer.file(path! as File);
            final File _file = File(path!);
            ChatAPI.uploadedFile = File(path!);



            api.sendFile(_file, _fileName, kIsWeb);
          }
        });
      }
    } else {
      // User canceled the picker
    }
  }

  void _handleUpload(BuildContext context) {
    // CHANGE 1; REQUIRES DEBUG.
    // changeMainFile(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: fetchFiles(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    // Return a loading indicator or placeholder widget
    return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
    // Handle errors
    return Center(child: Text('Error: ${snapshot.error}'));
    } else {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _blue,
        title: Text(''),
      ),
      body: Container(
        color: _blue,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Upload Your Documents',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                await pickFile();
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  color: _white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload,
                        size: 50,
                        color: _blue,
                      ),
                      Center(
                        child: Text(
                          'Click Here To Add File',
                          style: TextStyle(color: _blue, fontSize: 20.0),
                        ),
                      ),
                      if (_fileName.isNotEmpty)
                        Text(
                          'Uploaded File: $_fileName',
                          style: TextStyle(fontSize: 16, color: _blue),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(_gold),
                ),
                onPressed: () {

                  // String element = _fileName;
                  // api.userFiles.remove(element);
                  // api.userFiles.insert(0, element);

                  String element = _fileName;
                  if (api.userFiles.contains(element)) {
                    api.userFiles.remove(element);
                    api.userFiles.insert(0, element);
                  } else {

                    api.userFiles.insert(0, element);
                    // Element is not present, do nothing
                  }

                  _handleUpload(context);
                },
                child: Text(
                  'Continue',
                  style: TextStyle(color: _blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _uploadedFileNames.length,
                itemBuilder: (BuildContext context, int index) {
                  final fileName = _uploadedFileNames[index];
                  return ListTile(
                    title: Text(fileName),
                    trailing: Icon(Icons.check_circle, color: Colors.green),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
});
  }
        }

