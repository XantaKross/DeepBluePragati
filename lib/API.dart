import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ChatAPI {
  var selectedOption = false; // False means gemini.
  var file;

  bool isUpdated = true; // assume user is going to do the awkward stuff initially.

  static File? uploadedFile;
  static Uint8List? _webUploadedFile;

  static set webUploadedFile(Uint8List? data) {
    _webUploadedFile = data;
  }
  static Uint8List? get webUploadedFile {
    return _webUploadedFile;
  }

  String? csrfToken;
  final dio = Dio(); // This enables sending credentials (cookies, authentication headers) with requests);
  final cookieJar = CookieJar();
  Map<String, dynamic> headers = {};
  Map<String, dynamic> recievedData = {};
  late String Host;
  late String userkey;
  List userFiles = [];
  late Map dashBoard = {};

  @override
  void initState() {
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<List<Map<String, String>>> getDashBoard() async {
    String endpoint = "$Host/DashAPI";

    Map data = {};

    data["file"] = this.userFiles[0]; // Current main file.
    Response response = await dio.post(endpoint,
        data: jsonEncode(data),
        options: Options(
          headers: headers,
        ));

    Map<String, dynamic> jsonResponse = (response.data);
    List<Map<String, String>> qaList = [];

    jsonResponse.forEach((question, answer) {
      qaList.add({question: answer.toString()});
    });

    return qaList;
  }

  Future<bool> LogIn(String mail, String password) async {
    String endpoint = "$Host/LogSignIn";

    Response response = await dio.post(endpoint,
        data: jsonEncode(
            {"mail": mail, "password": password, "mode": "login"}), // Login
        options: Options(
          headers: headers,
        ));

    if (response.data["confirmation"]) {
      userkey = mail;
    }

    return response.data["confirmation"];
  }

  Future<bool> SignIn(
    String mail,
    String password,
  ) async {
    String endpoint = "$Host/LogSignIn";

    Response response = await dio.post(endpoint,
        data: jsonEncode(
            {"mail": mail, "password": password, "mode": "signin"}), // Signin
        options: Options(
          headers: headers,
        ));

    if (response.data["confirmation"]) {
      userkey = mail;
    }

    //this.cred = // Credentials.
    return response.data["confirmation"];
  }

  // Gets the CSRF token for further processing. This approach doesn't involve setting the "Cookie" header directly.
  Future getCSRF(bool kIsWeb) async {
    if (kIsWeb) {
      Host = "http://127.0.0.1:1803";
    } else {
      Host = "http://10.0.2.2:1803";
    }

    String endpoint =
        "$Host/FileAPI"; // Assuming this endpoint returns the CSRF token

    Response response = await dio.get(endpoint,
        options: Options(
          headers: headers,
        ));

    if (!kIsWeb) {
      // If it is not web the process the cookie properly.
      String setCookieHeader = '';

      for (String header in response.headers['set-cookie']!) {
        if (header.startsWith('csrftoken=')) {
          setCookieHeader = header;
          break;
        }
      }
      csrfToken = setCookieHeader.split(';')[0].split('=')[1];
    }

    if (response.statusCode == 200) {
      // Check for successful response
      headers["Cookie"] = 'csrftoken=$csrfToken';
      headers['X-CSRFToken'] = csrfToken;
      //dio.options.extra['withCredentials'] = true;
      //String csrfToken = response.data['csrftoken']; // Assuming token is in response data.
    } else {
      throw Exception(
          'Failed to retrieve CSRF token. Status code: ${response.statusCode}');
    }
  }

  Future deleteFile(int index) async {
    String endpoint = "$Host/FileAPI";

    Map data = {};

    data["fileName"] = this.userFiles[index];
    data["userKey"] = this.userkey;
    data["mode"] = "Delete";
    Response response = await dio.post(endpoint,
        data: jsonEncode(data),
        options: Options(
          headers: headers,
        ));

    this.userFiles.removeAt(index);
  }

  // is updated true or false?
  Future getFiles() async { // Need to change this so I get last used PDF.
    String endpoint = "$Host/FileAPI";

    Map data = {};

    data["userKey"] = this.userkey;
    data["mode"] = "Recieve";
    Response response = await dio.post(endpoint,
        data: jsonEncode(data),
        options: Options(
          headers: headers,
        ));

    if (response.data["userFiles"] != null) {
    this.userFiles = response.data["userFiles"];
  }
  }

  // Sends a file that is being uploaded onto the website backend for processing.
  Future sendFile(file, String fileName, bool kIsWeb) async {
    this.isUpdated = false;

    String endpoint = "$Host/FileAPI";

    if (!this.userFiles.contains(fileName)) {
      this.userFiles.insert(0, fileName); // Add the new file to the list.
    }
    else {
      this.userFiles.removeWhere((element) => element == fileName); // Delete the fileName from list.
      this.userFiles.insert(0, fileName); // Add it to the front of the list.
    }

    this.changeMainFile(); // Changes the main file to whatever was uploaded.

    Map data = {};

    if (!kIsWeb) {
      data['file'] = base64Encode(((await file.readAsBytes())
          .buffer
          .asUint8List())); //Change the image.
    } else {
      data['file'] = base64Encode(file);
      data["fileName"] = fileName;
    }

    data['userkey'] = this.userkey;
    data["mode"] = "Send";

    Response response = await dio.post(endpoint,
        data: jsonEncode(data),
        options: Options(
          headers: headers,
        ));

    // Sends file for processing.
  }

  // Gets a text that has been given by user and sends it to backend
  // Receives appropriate context and answer from backend and sends it to the
  // app.

  Future<(String, String)> communicate(String text) async {
    String endpoint = "$Host/TextAPI";

    // If new document is selected then read that document.
    // Otherwise answer with whatever document was read.

    Response response = await dio.post(endpoint,
        data: jsonEncode({"text": text, "model": this.selectedOption}),
        options: Options(
          headers: headers,
        ));

    print(response.data['aiMsg']);

    String reply =
        response.data["aiMsg"]; //"AI Based Replies not configured yet.";
    String context = response.data["context"];
    print(response.data["page_no"]);

    print(context);

    return (reply, context);
  }

  Future changeMainFile() async { // Change the main file on the server side of things.
    String endpoint = "$Host/ReaderAPI";

    Response response = await dio.post(endpoint,
        data: jsonEncode({"currentMain": this.userFiles[0]}),
        options: Options(
          headers: headers,
        ));

    // Let the server know which file to read. And remember.
  }

  Future getLatestFile() async {
    String endpoint = "$Host/GetLatestAPI";

    Response response = await dio.post(endpoint,
        data: jsonEncode({"currentMain": this.userFiles[0]}),
        options: Options(
          headers: headers,
        )
    );

    // either do this or just return the file and then change it properly.
    ChatAPI._webUploadedFile = await getFileAsUint8List(response.data);
    return null;
    // return ChatAPI._webUploadedFile;
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Use Stack for layering effects
      children: [
        // Faded background
        ModalBarrier(
            color: Colors.black
                .withOpacity(0.4)), // Adjust opacity for desired darkness

        // Centered loading indicator
        Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation(Colors.blue), // Customize color here
          ),
        ),
      ],
    );
  }
}


Future<Uint8List?> getFileAsUint8List(Map<String, dynamic> data) async {
  if (data.containsKey('file') && data['file'] is String) {
    final base64String = data['file'] as String;
    try {
      final bytes = base64Decode(base64String);
      return Uint8List.fromList(bytes);
    } on FormatException catch (e) {
      print('Invalid base64 string: $e');
      return null; // Or handle the error differently
    }
  } else {
    print('Missing or invalid "file" key in data map.');
    return null; // Or handle the missing key differently
  }
}
