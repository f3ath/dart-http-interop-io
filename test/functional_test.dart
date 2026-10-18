import 'dart:convert';
import 'dart:io';

import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';
import 'package:test/test.dart';

void main() {
  late HttpClient httpClient;
  late HttpServer httpServer;
  final host = 'localhost';
  final port = 8000;

  setUp(() async {
    httpClient = HttpClient();
    httpServer = await HttpServer.bind(host, port);
    httpServer.listenInterop(echoHandler);
  });

  tearDown(() {
    httpClient.close();
    return httpServer.close();
  });

  group('Functional', () {
    test('Preserves request path and query string', () async {
      final uri = Uri(
        scheme: 'http',
        host: host,
        port: port,
        path: '/search',
        queryParameters: {'q': 'hello world', 'page': '2'},
      );
      final rs = await httpClient.handleInterop(
        Request('GET', uri, Body(), Headers()),
      );
      final Map decoded = await rs.body.decodeJson();
      final receivedUri = Uri.parse(decoded['uri'] as String);

      expect(receivedUri.path, uri.path);
      expect(receivedUri.queryParameters, uri.queryParameters);
    });

    test('Echo', () async {
      final uri = Uri(scheme: 'http', host: host, port: port);
      final headers = {
        'Vary': ['Accept', 'Accept-Encoding'],
        'Accept': [
          'text/html',
          'application/xhtml+xml',
          'application/xml;q=0.9',
          'image/avif',
          'image/webp',
          'image/apng',
          '*/*;q=0.8',
          'application/signed-exchange;v=b3;q=0.7',
        ],
      };
      final rq = Request(
        'post',
        uri,
        Body.text('Hello', utf8),
        Headers.from(headers),
      );
      final rs = await httpClient.handleInterop(rq);

      expect(rs.statusCode, 200);
      final Map decoded = await rs.body.decodeJson();
      expect(decoded['method'], equals('post'));
      expect(decoded['body'], equals([72, 101, 108, 108, 111]));
      expect(decoded['headers']['vary'][0], startsWith('Accept'));
      expect(decoded['headers']['accept'][0], startsWith('text/html'));
      expect(
        rs.headers['set-cookie']![1],
        equals('k2=v2; Expires=Thu, 24 Feb 2033 07:28:00 GMT'),
      );
    });
  });
}

Future<Response> echoHandler(Request request) async {
  final body = Body.json({
    'method': request.method,
    'uri': request.uri.toString(),
    'headers': request.headers,
    'body': await request.body.bytes.expand((chunk) => chunk).toList(),
  });
  final headers = {
    'Content-Type': ['application/json'],
    'Set-Cookie': [
      'k1=v1; Expires=Thu, 24 Feb 2033 07:28:00 GMT',
      'k2=v2; Expires=Thu, 24 Feb 2033 07:28:00 GMT',
    ],
  };
  return Response(200, body, Headers.from(headers));
}
