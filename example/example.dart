import 'dart:io';

import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';

Future<void> main() async {
  final host = 'localhost';
  final server = await HttpServer.bind(host, 8080);
  server.listen(listener(HelloHandler()));

  ProcessSignal.sigint.watch().listen((event) async {
    await server.close(force: true);
    exit(0);
  });
  print('Listening on http://$host:${server.port}. Press Ctrl+C to stop.');
}

class HelloHandler implements Handler {
  @override
  Future<Response> handle(Request request) async {
    return Response(200, body: 'Hello! ${DateTime.now()}');
  }
}
