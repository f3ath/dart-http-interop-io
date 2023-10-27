import 'dart:convert';
import 'dart:io';

import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';
import 'package:test/test.dart';

void main() {
  HttpClient httpClient = HttpClient();
  late HttpServer httpServer;
  late Handler handler;
  final host = 'localhost';
  final port = 8000;

  setUp(() async {
    httpClient = HttpClient();
    handler = ClientWrapper(httpClient);
    httpServer = await HttpServer.bind(host, port);
    httpServer.listen(listener(EchoHandler()));
  });

  tearDown(() {
    httpClient.close();
    return httpServer.close();
  });

  group('Functional', () {
    test('Echo', () async {
      final uri = Uri(scheme: 'http', host: host, port: port);
      final headers = {
        'Vary': ['Accept', 'Accept-Encoding'],
      };
      final rq =
          Request('post', uri, Body.text('Hello', utf8), Headers.from(headers));
      final rs = await handler.handle(rq);

      expect(rs.statusCode, 200);
      final Map decoded = await rs.body.decodeJson();
      expect(decoded['method'], equals('post'));
      expect(decoded['body'], equals([72, 101, 108, 108, 111]));
      expect(rs.headers['set-cookie']![1],
          equals('k2=v2; Expires=Thu, 24 Feb 2033 07:28:00 GMT'));
    });
  });
}

class EchoHandler implements Handler {
  @override
  Future<Response> handle(Request request) async {
    final body = Body.json({
      'method': request.method,
      'headers': request.headers,
      'body': await request.body.bytes.expand((chunk) => chunk).toList()
    });
    final headers = {
      'Content-Type': ['application/json'],
      'Set-Cookie': [
        'k1=v1; Expires=Thu, 24 Feb 2033 07:28:00 GMT',
        'k2=v2; Expires=Thu, 24 Feb 2033 07:28:00 GMT'
      ]
    };
    return Response(200, body, Headers.from(headers));
  }
}
