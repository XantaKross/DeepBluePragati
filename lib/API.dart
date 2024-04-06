import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class API {
  static File? uploadedFile;
  static Uint8List? _webUploadedFile;

  static set webUploadedFile(Uint8List? data) {
    _webUploadedFile = data;
  }

  static Uint8List? get webUploadedFile {
    return _webUploadedFile;
  }
}
