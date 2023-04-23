import 'dart:convert';
import 'dart:io' as io;

import 'package:http_interop/http_interop.dart';

/// Wraps the [handler] into a listener for [HttpServer].
Future<void> Function(io.HttpRequest) listener(HttpHandler handler) =>
    (request) async {
      final headers = <String, String>{};
      request.headers.forEach((k, v) => headers[k] = v.join(','));
      handler
          .handle(HttpRequest(request.method, request.requestedUri,
              body: await request
                  .cast<List<int>>()
                  .transform(utf8.decoder)
                  .join())
            ..headers.addAll(headers))
          .then((response) {
        response.headers.forEach(request.response.headers.add);
        request.response.statusCode = response.statusCode;
        request.response.write(response.body);
        request.response.close();
      });
    };
