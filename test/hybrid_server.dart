import 'dart:io';

import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';
import 'package:stream_channel/stream_channel.dart';

void hybridMain(StreamChannel channel, Object message) async {
  final host = 'localhost';
  final port = 8000;
  final server = await HttpServer.bind(host, port);
  server.listen(listener(HelloHandler()));
  channel.sink.add('http://$host:$port');
}

class HelloHandler implements Handler {
  @override
  Future<Response> handle(Request request) async {
    return Response(200, body: 'Hello! ${DateTime.now()}');
  }
}
