import 'dart:convert';
import 'dart:io';

import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';

Future<void> main() async {
  final host = 'localhost';
  final port = 8080;
  final server = await HttpServer.bind(host, port);
  server.listen(listener(HelloHandler()));

  ProcessSignal.sigint.watch().listen((event) async {
    stderr.writeln('$event received, exiting');
    await server.close(force: true);
    exit(0);
  });
  print('Listening on http://$host:$port. Press Ctrl+C to stop.');
}

class HelloHandler implements Handler {
  @override
  Future<Response> handle(Request request) async =>
      Response(200, Body('Hello! ${DateTime.now()}', utf8), Headers({}));
}
