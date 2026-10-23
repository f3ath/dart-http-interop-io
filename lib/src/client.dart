import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http_interop/http_interop.dart';

import 'headers.dart';

extension HttpClientExt on io.HttpClient {
  /// Sends [request] using this client and returns a streaming response.
  ///
  /// Preserves this client's settings, including automatic decompression.
  /// By default, uses [HttpClientResponseExt.toInterop], which copies headers
  /// without modification even when the body has been decompressed.
  ///
  /// If provided, [responseConverter] replaces the default conversion. It
  /// receives the native response after headers arrive, before the body is read
  /// by this adapter, and may return a [Response] synchronously or asynchronously.
  /// Its result is awaited and returned; conversion errors propagate through
  /// the returned future.
  ///
  /// The native body stream can only be listened to once. A converter that
  /// consumes it must provide a replacement body in the returned response.
  Future<Response> sendInterop(
    Request request, {
    FutureOr<Response> Function(io.HttpClientResponse)? responseConverter,
  }) async {
    final clientRequest = await openUrl(request.method, request.uri);
    request.headers.forEach(clientRequest.headers.add);
    await clientRequest.addStream(request.body.bytes);
    final clientResponse = await clientRequest.close();
    return responseConverter == null
        ? clientResponse.toInterop()
        : await responseConverter(clientResponse);
  }
}

extension HttpClientResponseExt on io.HttpClientResponse {
  /// Converts this response to an interop response without consuming its body.
  ///
  /// Copies the status code and headers and shares this response's body stream.
  /// The body can only be listened to once, through either response.
  /// Headers are copied without modification, including when this client has
  /// automatically decompressed the body.
  Response toInterop() => Response(
    statusCode,
    Body(
      map((chunk) => chunk is Uint8List ? chunk : Uint8List.fromList(chunk)),
    ),
    headers.toInterop(),
  );
}
