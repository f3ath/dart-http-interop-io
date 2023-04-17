import 'dart:io';

import 'package:http_interop/http_interop.dart';
import 'package:http_interop_http/http_interop_http.dart';
import 'package:http_interop_io/http_interop_io.dart';
import 'package:test/test.dart';

void main() {
  final client = DisposableHandler();
  late HttpServer server;
  final host = 'localhost';
  final port = 8000;

  setUp(() async {
    server = await HttpServer.bind(host, port);
    server.listen(listener(HelloHandler()));
  });

  tearDown(() => server.close());

  test('Send/Receive', () async {
    final request = Request('GET', Uri.parse('http://$host:$port'));
    final response = await client.handle(request);
    expect(response.body, startsWith('Hello'));
  }, testOn: 'vm');
}

class HelloHandler implements Handler {
  @override
  Future<Response> handle(Request request) async =>
      Response(200, body: 'Hello! ${DateTime.now()}');
}
