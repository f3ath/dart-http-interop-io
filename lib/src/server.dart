import 'dart:async';
import 'dart:io' as io;

import 'package:http_interop/http_interop.dart';

import 'headers.dart';

extension ServerExt on io.HttpServer {
  StreamSubscription<io.HttpRequest> listenInterop(
    Handler handler, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      listen(
        handler.toListener(),
        onDone: onDone,
        onError: onError,
        cancelOnError: cancelOnError,
      );
}

extension on Handler {
  Future<void> Function(io.HttpRequest) toListener() =>
      (request) => this(request.toInterop()).then(request.response.send);
}

extension on io.HttpResponse {
  Future<void> send(Response response) async {
    response.headers.forEach(headers.add);
    statusCode = response.statusCode;
    await addStream(response.body.bytes);
    await close();
  }
}

extension on io.HttpRequest {
  /// Converts this request to an interop request.
  Request toInterop() =>
      Request(method, requestedUri, Body.stream(this), headers.toInterop());
}
