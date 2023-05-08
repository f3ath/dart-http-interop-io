import 'dart:io' as io;

import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/src/extensions.dart';

/// Wraps the [handler] into a listener for [HttpServer].
Future<void> Function(io.HttpRequest) listener(HttpHandler handler) =>
    (request) =>
        request.toInterop().then(handler.handle).then(request.response.send);
