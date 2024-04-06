// ignore_for_file: unused_field, file_names, prefer_const_constructors, unused_element, use_key_in_widget_constructors, prefer_final_fields, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_print, prefer_const_constructors_in_immutables, deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pragati_1/pdf_test.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pragati_1/upload_page.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'API.dart';
// import 'upload_page.dart';

Color _gold = Color(0xFFD4A064);
Color _white = Color(0xFFF2F5F8);
Color _blue = Color(0xFF1C2541);
Color _red = Color(0xFFCC4E5C);
Color _blue_1 = Color(0xFF7f30fe);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consult with FileName',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  File? _file;
  List<bool> isSelected = [
    true,
    false
  ]; // Assuming 'Gyan' is initially selected
  List fileNames = [
    'File_name 1',
    'File_name 2',
    'File_name 3',
    'File_name 4',
    'File_name 5',
  ];
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool isBotTyping = false;
  FocusNode _textFieldFocus = FocusNode();
  bool _showMicIcon = true;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String text = '';
  double _confidence = 1.0;
  String _fileName = '';
  List<String> _uploadedFileNames = [];

  @override
  void initState() {
    super.initState();
    _textFieldFocus.addListener(_onTextFieldFocusChange);
    _speech = stt.SpeechToText();
  }

  // Future pickFile() async {
  //   FilePickerResult? result =
  //       await FilePicker.platform.pickFiles(allowMultiple: false);

  //   if (result != null) {
  //     if (mounted) {
  //       setState(() {
  //         _fileName = result.files.single.name;
  //         _uploadedFileNames.add(_fileName);

  //         if (kIsWeb) {
  //           final data = result.files.single.bytes;
  //           final base64EncodedData = base64Encode(data!);
  //           final File _file =
  //               File('data:application/octet-stream;base64,$base64EncodedData');

  //           // Do something with the file data, like sending it to the server
  //         } else {
  //           var path = result.files.first.path;
  //           final File _file = File(path!);
  //           //  api.sendFile(_file, _fileName);
  //         }
  //       });
  //     }
  //   } else {
  //     // User canceled the picker
  //   }
  // }
  Future pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      if (mounted) {
        setState(() {
          _fileName = result.files.single.name;
          _uploadedFileNames.add(_fileName);

          if (kIsWeb) {
            final data = result.files.single.bytes;
            final base64EncodedData = base64Encode(data!);
            API.webUploadedFile = data as Uint8List;
          } else {
            final path = result.files.first.path;
            SfPdfViewer.file(path! as File);
            // final File _file = File(path!);
            API.uploadedFile = File(path!);
            //  api.sendFile(_file, _fileName);
          }
        });
      }
    } else {
      // User canceled the picker
    }
  }

  void _onTextFieldFocusChange() {
    setState(() {
      _showMicIcon = !_textFieldFocus.hasFocus;
    });
  }

  void _logout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Myupload()),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _blue,
        title: Center(
          child: Text(
            'Consult with ',
            style: TextStyle(color: _gold),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_blue, _blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: _gold,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add your login logic here
              // _handleLogin();
              _logout(context);
            },
            icon: Icon(
              Icons.logout,
              color: _gold,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    //color: _blue,
                    padding: EdgeInsets.all(4), // Reduced padding
                    width: 100.0, // Set a specific width
                    height: 100.0,

                    child: Image.asset(
                      'assets/Gyan.jpg', // Replace with the actual path to your image
                      fit:
                          BoxFit.fitHeight, // Adjust the fit property as needed
                    ),
                  ),
                  Center(
                    child: ToggleButtons(
                      borderColor: Colors.black,
                      fillColor: _gold,
                      borderWidth: 2,
                      selectedBorderColor: Colors.black,
                      selectedColor: _gold,
                      borderRadius: BorderRadius.circular(8),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Gyan',
                              style: TextStyle(color: _blue),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Gemini',
                              style: TextStyle(color: _blue),
                            ),
                          ),
                        ),
                      ],
                      onPressed: (int index) {
                        setState(() {
                          for (int buttonIndex = 0;
                              buttonIndex < isSelected.length;
                              buttonIndex++) {
                            if (buttonIndex == index) {
                              isSelected[buttonIndex] = true;
                            } else {
                              isSelected[buttonIndex] = false;
                            }
                          }
                        });
                      },
                      isSelected: isSelected,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PDFViewerScreen()),
                        );
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.picture_as_pdf_rounded),
                              SizedBox(
                                width: 10,
                              ),
                              Center(
                                child: Text(
                                  'Read PDF',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AboutListTile(
                      icon: Icon(Icons.info),
                      child: Text('About Us'),
                      applicationName: 'My App',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2024 My Company',
                      aboutBoxChildren: [
                        Text('This app is developed by Team Adapt.'),
                        Text('It helps you with your Flutter code.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history),
                      SizedBox(width: 10),
                      Text(
                        'History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200, // Set a fixed height for the ListView
                    child: ListView.builder(
                      itemCount: fileNames
                          .length, // Replace fileNames with your list of file names
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Add your logic for button tap here
                                      // You can access the file name using fileNames[index]
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.file_copy),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Center(
                                            child: Text(fileNames[index]),
                                          ),
                                        ],
                                      ), // Display the file name
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.delete)),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: _white,
          // image: DecorationImage(
          //   image: AssetImage(
          //       "assets/images/bot_background.jpeg"), // Replace with your asset image
          //   fit: BoxFit.cover,
          // ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // Display messages in reverse order
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            _buildMessagePrompt(),
            _buildMessageComposer(),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagePrompt() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: _messages.isNotEmpty && !_messages.first.isUser
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isBotTyping
                    ? Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 8.0),
                          Text('AI Assistant is typing...'),
                        ],
                      )
                    : Container(),
                SizedBox(height: 5.0),
              ],
            )
          : Container(),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _blue,
        border: Border.all(
          color: Color(0xFFD4A064),
          width: 2.0,
        ), // add a border

        borderRadius: BorderRadius.circular(50.0), // make it curved
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () async {
                await pickFile();

                // setState(() {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => MyWidget()),
                //   );
                // });
              },
              icon: Icon(
                Icons.picture_as_pdf,
                color: _gold,
              )),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _textFieldFocus,
              textInputAction: TextInputAction.send,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a FAQ Prompt...',
                hintStyle: TextStyle(color: _gold),
              ),
              style: TextStyle(color: _gold),
            ),
          ),
          if (_showMicIcon)
            IconButton(
              icon: Icon(
                Icons.mic,
                color: _gold,
              ),
              onPressed: () {
                // Handle microphone button press
                _listen();
              },
            ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: _gold,
            ),
            onPressed: () {
              _handleSubmitted(_messageController.text);
            },
          ),
        ],
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            text = val.recognizedWords;
            // _messageController = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
            _messageController.text = text;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleSubmitted(String text) async {
    _messageController.clear();

    ChatMessage userMessage = ChatMessage(
      text: text,
      isUser: true,
      context: '',
    );

    setState(() {
      // Wait for server reply.
      _messages.insert(0, userMessage);
      isBotTyping = true;
    });

    // Send the user text to server
    // var (reply, context) = (await api.communicate(text)) ;

    ChatMessage aiMessage = ChatMessage(
      text: 'Sample Text', //reply,
      isUser: false,
      context: 'Sample', //,
    );

    setState(() {
      isBotTyping = false;
      _messages.insert(0, aiMessage);
    });
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final String context;

  ChatMessage(
      {required this.text, required this.isUser, required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        //crossAxisAlignment: CrossAxisAlignment.start,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isUser
                ? CircleAvatar(
                    child: Icon(Icons.person),
                    backgroundColor: _blue,
                    foregroundColor: _white,
                  )
                : CircleAvatar(
                    child: Icon(Icons.android),
                    backgroundColor: _blue,
                    foregroundColor: _white,
                  ),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser ? 'You' : 'GYAN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _white,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_blue, _blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: _gold, // Gold color for the border
                          width: 2.0, // Width of the border
                        ),
                        color: isUser ? _blue : _blue,
                        borderRadius: BorderRadius.circular(
                            10.0)), // Use a ternary operator to check if the message is from the user or the AI assistant
                    child: Text(
                      text,
                      style: TextStyle(color: _gold),
                    ),
                  ),
                  if (!isUser) // Only show the button when the message is from the AI
                    Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.topLeft,
                        child: TextButton(
                          child: Text(
                            'Click here to view Context',
                            style: TextStyle(color: _blue),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _white,
                            backgroundColor: _gold,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Center(
                                    child: Text(
                                  'Context',
                                  style: TextStyle(color: _blue),
                                )), // Customize the title
                                content: Text(
                                  'Enter the additional context for your message:' *
                                      50,
                                  style:
                                      TextStyle(color: _gold, fontSize: 16.0),
                                ),
                              ),
                            );
                          },
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
