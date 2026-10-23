import 'dart:async';
import 'dart:io' as io;

import 'package:http_interop/http_interop.dart';

import 'headers.dart';

extension ServerExt on io.HttpServer {
  /// Handles incoming requests with [handler] and sends its responses.
  ///
  /// Converts each request to an interop request with a streaming body, then
  /// writes the handler's response status, headers, and body and closes the
  /// native response. Requests are handled concurrently.
  ///
  /// Forwards [onError], [onDone], and [cancelOnError] to [io.HttpServer.listen].
  /// These callbacks concern the server's request stream: [onError] does not
  /// receive handler or response-writing failures, and [onDone] does not wait
  /// for in-flight handlers to finish.
  ///
  /// Handler and response-writing failures are reported to the current zone as
  /// uncaught errors. No error response is generated automatically; handlers
  /// should catch application errors and return an appropriate response.
  StreamSubscription<io.HttpRequest> listenInterop(
    Handler handler, {
    Function? onError,
    void Function()? onDone,
    bool cancelOnError = false,
  }) => listen(
    (request) => handler(
      Request(
        request.method,
        request.requestedUri,
        Body(request),
        request.headers.toInterop(),
      ),
    ).then(request.response.send),
    onDone: onDone,
    onError: onError,
    cancelOnError: cancelOnError,
  );
}

extension on io.HttpResponse {
  Future<void> send(Response response) async {
    response.headers.forEach(headers.add);
    statusCode = response.statusCode;
    await addStream(response.body.bytes);
    await close();
  }
}
