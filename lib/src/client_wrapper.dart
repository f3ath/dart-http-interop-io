import 'dart:io';
import 'dart:typed_data';

import 'package:http_interop/http_interop.dart';

extension HttpClientExt on HttpClient {
  Handler interopHandler() => (Request request) async {
        final rq = await open(request.method, request.uri.host,
            request.uri.port, request.uri.path);
        request.headers.forEach((key, values) {
          for (final element in values) {
            rq.headers.add(key, element);
          }
        });
        await request.body.bytes.forEach(rq.add);
        final rs = await rq.close();
        final headers = <String, List<String>>{};
        rs.headers.forEach((name, values) {
          headers[name] = values;
        });
        return Response(rs.statusCode, Body.stream(rs.map(Uint8List.fromList)),
            Headers.from(headers));
      };
}
