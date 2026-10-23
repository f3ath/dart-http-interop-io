import 'dart:io';

import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';

Future<void> main() async {
  const host = 'localhost';
  const port = 8080;
  final server = await HttpServer.bind(host, port);
  server.listenInterop(sayHello);

  print('Listening on http://$host:$port. Press Ctrl+C to stop.');
  final signal = await ProcessSignal.sigint.watch().first;
  stderr.writeln('$signal received, exiting');
  await server.close(force: true);
}

Future<Response> sayHello(Request request) async =>
    Response(200, Body.text('Hello! You requested ${request.uri}'), Headers());
