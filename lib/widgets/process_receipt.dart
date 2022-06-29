import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../storage_service.dart';

class ProcessReceipt extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;
  // DateTime date;
  final Function setDate;

  ProcessReceipt(this.titleController, this.amountController, this.setDate);

  @override
  State<ProcessReceipt> createState() => _ProcessReceiptState();
}

class _ProcessReceiptState extends State<ProcessReceipt> {
  final Storage storage = Storage();
  String imageUrl;
  String imagePath;
  String imageName;

  bool isLoading = false;

  takeImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (con) {
          return SimpleDialog(
            title: Text(
              "Receipt image",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Capture image with camera",
                  style: Theme.of(context).textTheme.headline4,
                ),
                onPressed: captureImageFromCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Select image from gallery",
                  style: Theme.of(context).textTheme.headline4,
                ),
                onPressed: selectImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.headline4,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  captureImageFromCamera() async {
    Navigator.pop(context);
    XFile imageFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      setState(() {
        imagePath = imageFile.path;
        imageName = imageFile.name;
        isLoading = true;
      });

      imageUrl = await storage.uploadFile(imagePath, imageName);
      print('Image uploaded to firebase');

      call();
    }
  }

  selectImageFromGallery() async {
    Navigator.pop(context);
    XFile imageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No image selected"),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    setState(() {
      imagePath = imageFile.path;
      imageName = imageFile.name;
      isLoading = true;
    });

    imageUrl = await storage.uploadFile(imagePath, imageName);
    print('Image uploaded successfully');

    call();
  }

  Future<void> call() async {
    try {
      Map body = {
        "imageUrl": imageUrl,
      };

      var response = await http.post(
        Uri.parse("https://afternoon-bayou-05068.herokuapp.com/readReceipt"),
        body: body,
      );

      var result = jsonDecode(response.body);

      if (result['status']) {
        setState(() {
          isLoading = false;
        });

        widget.titleController.text = result['title'].toString();
        widget.amountController.text = result['amount'].toString();

        widget.setDate(DateFormat('dd.MM.yyyy').parse(result['date']));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: !isLoading
          ? TextButton.icon(
              onPressed: () => takeImage(context),
              icon: Icon(
                Icons.camera_alt_outlined,
                size: 24.0,
              ),
              label: Text('Upload receipt'),
            )
          : Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).accentColor,
                size: 40,
              ),
            ),
    );
  }
}
