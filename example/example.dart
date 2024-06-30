import 'dart:convert';
import 'dart:io';

import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';

Future<void> main() async {
  const host = 'localhost';
  const port = 8080;
  final server = await HttpServer.bind(host, port);
  server.listenInterop(sayHello);

  ProcessSignal.sigint.watch().listen((event) async {
    stderr.writeln('$event received, exiting');
    await server.close(force: true);
    exit(0);
  });
  print('Listening on http://$host:$port. Press Ctrl+C to stop.');
}

Future<Response> sayHello(Request request) async =>
    Response(200, Body.text('Hello! ${DateTime.now()}', utf8), Headers());
