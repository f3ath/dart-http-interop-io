import 'dart:io';

import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';
import 'package:test/test.dart';

void main() {
  late HttpClient client;
  late HttpServer server;
  final host = 'localhost';

  setUp(() async {
    client = HttpClient();
    server = await HttpServer.bind(host, 0);
  });

  tearDown(() async {
    client.close(force: true);
    await server.close(force: true);
  });

  group('Functional', () {
    test('Awaits responseConverter and returns its response', () async {
      server.listenInterop(echoHandler);
      final uri = Uri(scheme: 'http', host: host, port: server.port);
      Response? observedResponse;
      var calls = 0;

      final response = await client.sendInterop(
        Request('GET', uri, Body.empty(), Headers()),
        responseConverter: (native) async {
          calls++;
          await Future<void>.delayed(Duration.zero);
          final interop = native.toInterop();
          observedResponse = interop;
          interop.context['compressionState'] = native.compressionState;
          return interop;
        },
      );

      expect(calls, 1);
      expect(observedResponse, same(response));
      expect(
        response.context['compressionState'],
        HttpClientResponseCompressionState.notCompressed,
      );
      final Map decoded = await response.body.decodeJson();
      expect(decoded['method'], 'GET');
    });

    test('Supports a synchronous responseConverter', () async {
      server.listenInterop(echoHandler);
      final uri = Uri(scheme: 'http', host: host, port: server.port);
      final response = await client.sendInterop(
        Request('GET', uri, Body.empty(), Headers()),
        responseConverter: (native) {
          final interop = native.toInterop();
          interop.headers['x-converted'] = ['true'];
          return interop;
        },
      );

      expect(response.headers['x-converted'], ['true']);
      final Map decoded = await response.body.decodeJson();
      expect(decoded['method'], 'GET');
    });

    test('Preserves request path and query string', () async {
      server.listenInterop(echoHandler);
      final uri = Uri(
        scheme: 'http',
        host: host,
        port: server.port,
        path: '/search',
        queryParameters: {'q': 'hello world', 'page': '2'},
      );
      final rs = await client.sendInterop(
        Request('GET', uri, Body.empty(), Headers()),
      );
      final Map decoded = await rs.body.decodeJson();
      final receivedUri = Uri.parse(decoded['uri'] as String);

      expect(receivedUri.path, uri.path);
      expect(receivedUri.queryParameters, uri.queryParameters);
    });

    test(
      'Preserves request data and multiple Set-Cookie response headers',
      () async {
        server.listenInterop(echoHandler);
        final uri = Uri(scheme: 'http', host: host, port: server.port);
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
          'POST',
          uri,
          Body.text('Hello'),
          Headers.from(headers),
        );
        final rs = await client.sendInterop(rq);

        expect(rs.statusCode, 200);
        final Map decoded = await rs.body.decodeJson();
        expect(decoded['method'], equals('POST'));
        expect(decoded['body'], equals([72, 101, 108, 108, 111]));
        expect(decoded['headers']['vary'][0], startsWith('Accept'));
        expect(decoded['headers']['accept'][0], startsWith('text/html'));
        expect(
          rs.headers['set-cookie']![1],
          equals('k2=v2; Expires=Thu, 24 Feb 2033 07:28:00 GMT'),
        );
      },
    );
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
