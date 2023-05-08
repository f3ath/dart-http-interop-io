import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http_interop/http_interop.dart';

extension HttpHeadersExt on io.HttpHeaders {
  /// Returns the folded headers.
  Map<String, String> folded() {
    final result = <String, String>{};
    forEach((key, value) => result[key] = value.join(','));
    return result;
  }
}

extension HttpRequestExt on io.HttpRequest {
  /// Converts this request to an interop request.
  Future<HttpRequest> toInterop() =>
      body().then((body) => HttpRequest.binary(method, requestedUri, body,
          headers: headers.folded()));

  /// Reads the full body of the request.
  Future<Uint8List> body() =>
      expand((e) => e).toList().then(Uint8List.fromList);
}

extension HttpResponseExt on io.HttpResponse {
  Future<void> send(HttpResponse response) async {
    response.headers.forEach(headers.add);
    statusCode = response.statusCode;
    write(response.body);
    await close();
  }
}
