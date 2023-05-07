import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http_interop/http_interop.dart';

/// Wraps the [handler] into a listener for [HttpServer].
Future<void> Function(io.HttpRequest) listener(HttpHandler handler) =>
    (request) async {
      final headers = <String, String>{};
      request.headers.forEach((k, v) => headers[k] = v.join(','));
      final body = Uint8List.fromList(await request.expand((e) => e).toList());
      handler
          .handle(HttpRequest.binary(request.method, request.requestedUri, body,
              headers: headers))
          .then((response) {
        response.headers.forEach(request.response.headers.add);
        request.response.statusCode = response.statusCode;
        request.response.write(response.body);
        request.response.close();
      });
    };
