import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http_interop/http_interop.dart';

import 'headers.dart';

extension HttpClientExt on io.HttpClient {
  Future<Response> handleInterop(Request request) async {
    final rq = await openUrl(request.method, request.uri);
    request.headers.forEach(rq.headers.add);
    await rq.addStream(request.body.bytes);
    final rs = await rq.close();
    return Response(
      rs.statusCode,
      Body.stream(
        rs.map(
          (chunk) => chunk is Uint8List ? chunk : Uint8List.fromList(chunk),
        ),
      ),
      rs.headers.toInterop(),
    );
  }
}
