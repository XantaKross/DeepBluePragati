import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pragati_a/login_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'API.dart';
import 'chart_data_models.dart';
import 'pdfviewerx.dart';
import 'upload_page.dart';

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
      title: 'Consult with ${api.selectedOption ? 'Gyan' : 'Gemini'}',
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
  bool changes =
      false; // simple boot to rewrite the UI tree. Coz setting it to a int may cause
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

  @override
  void initState() {
    super.initState();
    _textFieldFocus.addListener(_onTextFieldFocusChange);
    _speech = stt.SpeechToText();
  }

  Future pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      if (mounted) {
        setState(() {
          _fileName = result.files.single.name;
          api.isUpdated = true;

          if (kIsWeb) {
            final data = result.files.single.bytes;
            ChatAPI.webUploadedFile = data as Uint8List;

            api.sendFile(data, _fileName, kIsWeb);
          } else {
            var path = result.files.first.path;
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

  void _onTextFieldFocusChange() {
    setState(() {
      _showMicIcon = !_textFieldFocus.hasFocus;
    });
  }

  void handleDeleteFile(int index) async {
    await api.deleteFile(index);
    setState(() {
      changes = !changes;
    });
    api.isUpdated = true;
    changeMainFile(context);
  }

  void rearrangeFiles() async {
    setState(() {
      changes = !changes;
    });
    api.isUpdated = true;
    changeMainFile(context);
  }

  void _logout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentsLogin()),
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
            'Consult with ${api.selectedOption ? 'Gyan' : 'Gemini'}',
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
                      'Gyan.jpg', // Replace with the actual path to your image
                      fit:
                          BoxFit.fitHeight, // Adjust the fit property as needed
                    ),
                  ),
                  Center(
                    child: ToggleButtons(
                      borderColor: Colors.black,
                      fillColor:
                          _gold, // Color for both selected and unselected buttons
                      borderWidth: 2,
                      selectedBorderColor:
                          Colors.black, // Border color remains black
                      selectedColor: Colors
                          .transparent, // Make selected button background transparent
                      borderRadius: BorderRadius.circular(8),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Gyan',
                            style: TextStyle(
                              color: api.selectedOption
                                  ? Colors.blueGrey[900]
                                  : _blue, // Dark blue for selected, blue for unselected
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Gemini',
                            style: TextStyle(
                              color: !api.selectedOption
                                  ? Colors.blueGrey[900]
                                  : _blue, // Dark blue for unselected, blue for selected (inverted logic)
                            ),
                          ),
                        ),
                      ],
                      onPressed: (int index) {
                        setState(() {
                          api.selectedOption = !api
                              .selectedOption; // Toggle the state on button press
                        });
                      },
                      isSelected: [
                        api.selectedOption,
                        !api.selectedOption
                      ], // Create a list based on the single bool
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      // var localFile = await api.file;

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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardAp()),
                      );
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
                              Icon(Icons.dashboard),
                              SizedBox(
                                width: 10,
                              ),
                              Center(
                                child: Text(
                                  'Dashboard',
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
                      itemCount: api.userFiles.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: InkWell(
                                    onTap: () {
                                      String element = api.userFiles[index];
                                      api.userFiles.remove(element);
                                      api.userFiles.insert(0, element);
                                      rearrangeFiles();
                                    },
                                    splashColor: Colors.grey[400],
                                    child: Padding(
                                      // Add padding
                                      padding: const EdgeInsets.all(
                                          4.0), // Adjust padding as needed
                                      child: Container(
                                        // Transparent container
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Container(
                                          // Inner container with background
                                          padding: const EdgeInsets.all(
                                              4.0), // Match outer padding
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.file_copy),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Text(
                                                    api.userFiles[index],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: IconButton(
                                      onPressed: () => handleDeleteFile(index),
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
                changeMainFile(context);
                setState(() {
                  changes = !changes;
                });
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
                color: _isListening ? _red : _gold,
              ),
              onPressed: () {
                if (_isListening) {
                  _messageController.clear();
                  _speech.stop();
                  setState(() => _isListening = false);
                } else {
                  // Start listening
                  _listen();
                }
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
          onResult: (val) {
            setState(() {
              text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
              _messageController.text = text;
            });
          },
          listenFor: Duration(seconds: 8),
          cancelOnError: true,
          partialResults: true,
        );
        Future.delayed(Duration(seconds: 8), () {
          if (_isListening) {
            _speech.stop();
            setState(() => _isListening = false);
          }
        });
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
    var (reply, context) = (await api.communicate(text));

    ChatMessage aiMessage = ChatMessage(
      text: reply, //reply,
      isUser: false,
      context: context,
      //,
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
                                content: SingleChildScrollView(
                                  child: Text(
                                    this.context,
                                    style:
                                        TextStyle(color: _gold, fontSize: 16.0),
                                  ),
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
