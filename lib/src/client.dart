import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http_interop/http_interop.dart';

import 'headers.dart';

extension HttpClientExt on io.HttpClient {
  /// Sends [request] using this client and converts the native response.
  ///
  /// Preserves this client's settings, including automatic decompression.
  /// By default, uses [HttpClientResponseExt.toInterop], which copies headers
  /// without modification even when the body has been decompressed.
  /// The caller must consume or cancel the returned body stream to release
  /// connection resources.
  ///
  /// If provided, [responseConverter] replaces the default conversion. It
  /// receives the native response after headers arrive, before the body is read
  /// by this adapter, and may return a [Response] synchronously or asynchronously.
  /// Its result is awaited and returned; conversion errors propagate through
  /// the returned future.
  ///
  /// The native body stream can only be listened to once. A converter that
  /// consumes it must provide a replacement body in the returned response.
  /// On conversion failure, cancels the body if it has not been listened to.
  /// A converter that starts reading the body is responsible for completing or
  /// cancelling its subscription if it fails.
  ///
  /// If request setup or sending fails, aborts the native request and propagates
  /// the original error.
  Future<Response> sendInterop(
    Request request, {
    FutureOr<Response> Function(io.HttpClientResponse)? responseConverter,
  }) async {
    final clientRequest = await openUrl(request.method, request.uri);
    final io.HttpClientResponse clientResponse;
    try {
      request.headers.forEach(clientRequest.headers.add);
      await clientRequest.addStream(request.body.bytes);
      clientResponse = await clientRequest.close();
    } catch (error, stackTrace) {
      // Aborting also completes done with an error; report it through this
      // method's future rather than as a second, unhandled error.
      clientRequest.done.ignore();
      clientRequest.abort(error, stackTrace);
      rethrow;
    }
    try {
      return responseConverter == null
          ? clientResponse.toInterop()
          : await responseConverter(clientResponse);
    } catch (_) {
      try {
        await clientResponse.listen(null, onError: (Object error) {}).cancel();
      } catch (_) {
        // The converter may have already consumed the stream. Cleanup errors
        // must not replace the original conversion error.
      }
      rethrow;
    }
  }
}

extension HttpClientResponseExt on io.HttpClientResponse {
  /// Converts this response to an interop response without consuming its body.
  ///
  /// Copies the status code into a new [Response] with a new header map.
  /// Header value lists and the body stream are shared with this response.
  /// The body can only be listened to once, through either response.
  /// Consume or cancel it to release connection resources.
  ///
  /// Headers are copied without modification, including when the originating
  /// client has automatically decompressed the body.
  Response toInterop() => Response(
    statusCode,
    Body(
      map((chunk) => chunk is Uint8List ? chunk : Uint8List.fromList(chunk)),
    ),
    headers.toInterop(),
  );
}
