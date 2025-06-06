import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PredictPage extends StatefulWidget {
  @override
  _PredictPageState createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  File? _image;
  String _result = "No prediction yet";

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://<your-ngrok-url>/predict'), // 🔗 Replace with your actual ngrok URL
    );

    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final json = jsonDecode(respStr);
        setState(() {
          _result = "Prediction: ${json['prediction']}";
        });
      } else {
        setState(() {
          _result = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Exception: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Placeholder(fallbackHeight: 200),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image and Predict'),
            ),
            SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
