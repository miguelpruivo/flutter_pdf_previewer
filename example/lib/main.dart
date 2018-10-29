import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_previewer/pdf_previewer.dart';
import 'package:pdf_previewer_example/template_page_widget.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pdfPath = '';
  String _previewPath;
  bool _isLoading = false;
  int _pageNumber = 1;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  void _pickPDF() async {
    try {
      _pdfPath = await FilePicker.getFilePath(type: FileType.PDF);
      setState(() {});
      if (_pdfPath == '') {
        return;
      }
      print("File path: " + _pdfPath);
      setState(() {
        _isLoading = true;
      });
    } on PlatformException catch (e) {
      print("Error while picking the file: " + e.toString());
    }

    _previewPath = await PdfPreviewer.getPagePreview(filePath: _pdfPath, pageNumber: _pageNumber);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('PDF Previewer example app'),
        ),
        body: new SingleChildScrollView(
          child: new Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new TemplatePageWidget(
                    height: 370.0,
                    isLoading: _isLoading,
                    width: 280.0,
                    previewPath: _previewPath,
                  ),
                  new SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: new TextField(
                      decoration: InputDecoration(hintText: 'Page...'),
                      textAlign: TextAlign.center,
                      onSubmitted: (value) => _pageNumber = int.parse(value),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  new RaisedButton(
                    child: Text('Pick PDF'),
                    onPressed: _pickPDF,
                  ),
                  Text('File: ' + _pdfPath.split('/').last),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
