import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    String imageLink;

    try {
      await storage.ref('test/$fileName').putFile(file);
      imageLink = await storage.ref('test/$fileName').getDownloadURL();
    } on firebase_core.FirebaseException catch (e) {
      print(e.message);
    }

    return imageLink;
  }
}
