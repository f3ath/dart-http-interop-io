import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http_interop/http_interop.dart';

/// Converts the [handler] into a listener for [HttpServer].
Future<void> Function(io.HttpRequest) listener(Handler handle) =>
    (request) => request.toInterop().then(handle).then(request.response.send);

extension on io.HttpResponse {
  Future<void> send(Response response) async {
    response.headers.forEach(headers.add);
    statusCode = response.statusCode;
    await response.body.bytes.forEach(add);
    await close();
  }
}

extension on io.HttpRequest {
  /// Converts this request to an interop request.
  Future<Request> toInterop() =>
      expand((e) => e).toList().then(Uint8List.fromList).then((body) => Request(
          method, requestedUri, Body.binary(body), headers.toInterop()));
}

extension on io.HttpHeaders {
  /// Converts to [Headers].
  Headers toInterop() {
    final headers = <String, List<String>>{};
    forEach((name, values) {
      headers[name] = values;
    });
    return Headers.from(headers);
  }
}
