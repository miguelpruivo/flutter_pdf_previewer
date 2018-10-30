import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class PdfPreviewer {
  static const MethodChannel _channel = const MethodChannel('pdf_previewer');

  /// Creates a temporary PNG image for the provided [filePath]
  ///
  /// [pageNumber] defaults to `1` and must be equal or above it.
  static Future<dynamic> getPagePreview(
      {@required String filePath, int pageNumber = 1}) async {
    assert(pageNumber > 0 && filePath != null);
    return _channel.invokeMethod(
        'getPagePreview', {'filePath': filePath, 'pageNumber': pageNumber});
  }

  /// Creates a temporary PNG image for the last page of the provided PDF in [filePath]
  ///
  /// If the file has only a single page, it will return it.
  static Future<dynamic> getLastPagePreview({@required String filePath}) {
    assert(filePath != null);
    return _channel.invokeMethod('getLastPagePreview', {'filePath': filePath});
  }
}
