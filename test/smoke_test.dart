import 'dart:convert';
import 'dart:io';

import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_http/http_interop_http.dart';
import 'package:http_interop_io/http_interop_io.dart';
import 'package:test/test.dart';

void main() {
  final client = OneOffHandler();
  late HttpServer server;
  final host = 'localhost';
  final port = 8000;

  setUp(() async {
    server = await HttpServer.bind(host, port);
    server.listen(listener(HelloHandler()));
  });

  tearDown(() => server.close());

  test('Send/Receive', () async {
    final uri = Uri(scheme: 'http', host: host, port: port);
    final request = Request(Method('GET'), uri, Body.empty(), Headers({}));
    final response = await client.handle(request);
    expect(await response.body.decode(utf8), startsWith('Hello'));
  }, testOn: 'vm');
}

class HelloHandler implements Handler {
  @override
  Future<Response> handle(Request request) async =>
      Response(200, Body('Hello! ${DateTime.now()}', utf8), Headers({}));
}
