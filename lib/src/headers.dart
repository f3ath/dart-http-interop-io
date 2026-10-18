import 'dart:io' as io;

import 'package:http_interop/http_interop.dart';

extension HttpHeadersExt on io.HttpHeaders {
  /// Converts to [Headers].
  Headers toInterop() {
    final headers = Headers();
    forEach((name, values) {
      headers[name] = values;
    });
    return headers;
  }
}
