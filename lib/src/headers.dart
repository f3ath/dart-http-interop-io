import 'dart:io' as io;

import 'package:http_interop/http_interop.dart';

extension HttpHeadersExt on io.HttpHeaders {
  /// Converts these headers to a new [Headers] map.
  ///
  /// Retains the original value lists without copying them. Replacing a map
  /// entry affects only the new map; mutating a value list affects both.
  Headers toInterop() {
    final headers = Headers();
    forEach((name, values) {
      headers[name] = values;
    });
    return headers;
  }
}
