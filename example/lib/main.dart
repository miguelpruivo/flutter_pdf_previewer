import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_previewer/pdf_previewer.dart';

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

  Future<void> initPlatformState() async {
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

/// Displays an empty container that will represent a document page template with a fixed [width] and [height]
/// where the user will use to pick a coordenate.
/// [widgetWidth] should be called along with the [widgetHeight] in order to make the aspect ratio fit
class TemplatePageWidget extends StatefulWidget {
  final double width;
  final double height;
  final bool isLoading;
  final String previewPath;

  TemplatePageWidget({@required this.width, @required this.height, this.isLoading, this.previewPath})
      : assert(width > 0.0 && height > 0.0);
  TemplatePageState createState() => new TemplatePageState();
}

class TemplatePageState extends State<TemplatePageWidget> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Center(
        child: widget.previewPath != null
            ? new PdfPagePreview(
                imgPath: widget.previewPath,
              )
            : widget.isLoading
                ? new CircularProgressIndicator(
                    strokeWidth: 2.0,
                    value: null,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  )
                : new Text('Load a PDF file to see a preview'),
      ),
      height: widget.height,
      width: widget.width,
      decoration: new BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(spreadRadius: 1.0, color: Color(0xffebebeb), blurRadius: 3.0),
        ],
        border: Border.all(
          width: 1.0,
          color: Color(0xffebebeb),
        ),
        shape: BoxShape.rectangle,
      ),
    );
  }
}

class PdfPagePreview extends StatefulWidget {
  final String imgPath;
  PdfPagePreview({@required this.imgPath});
  _PdfPagePreviewState createState() => new _PdfPagePreviewState();
}

class _PdfPagePreviewState extends State<PdfPagePreview> {
  bool imgReady = false;
  ImageProvider provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPreview(needsRepaint: true);
  }

  @override
  void didUpdateWidget(PdfPagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imgPath != widget.imgPath) {
      _loadPreview(needsRepaint: true);
    }
  }

  void _loadPreview({@required bool needsRepaint}) {
    if (needsRepaint) {
      imgReady = false;
      provider = FileImage(File(widget.imgPath));
      final resolver = provider.resolve(createLocalImageConfiguration(context));
      resolver.addListener((imgInfo, alreadyPainted) {
        imgReady = true;
        if (!alreadyPainted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: imgReady
          ? new Image(
              image: provider,
            )
          : new CircularProgressIndicator(
              strokeWidth: 2.0,
              value: null,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
    );
  }
}
