import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class PdfPreviewer {
  static const MethodChannel _channel = const MethodChannel('pdf_previewer');

  static Future<dynamic> getPagePreview({@required String filePath, int pageNumber = 1}) async {
    assert(pageNumber > 0);
    return _channel.invokeMethod('getPagePreview', {'filePath': filePath, 'pageNumber': pageNumber});
  }

  static Future<dynamic> getLastPagePreview({@required String filePath}) async {
    assert(pageNumber > 0);
    return _channel.invokeMethod('getLastPagePreview', {'filePath': filePath});
  }
}
