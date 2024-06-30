import 'dart:io' as io;

import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/src/extensions.dart';

/// Converts the [handler] into a listener for [HttpServer].
Future<void> Function(io.HttpRequest) listener(Handler handle) =>
    (request) => request.toInterop().then(handle).then(request.response.send);
