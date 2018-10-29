import 'package:flutter/material.dart';
import 'package:pdf_previewer_example/pdf_page_preview.dart';

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
        boxShadow: [BoxShadow(spreadRadius: 1.0, color: Color(0xffebebeb), blurRadius: 3.0)],
        border: Border.all(width: 1.0, color: Color(0xffebebeb)),
        shape: BoxShape.rectangle,
      ),
    );
  }
}
