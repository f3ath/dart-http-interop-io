# http_interop_io

[Interop]-compatible adapters for the standard `dart:io` HTTP client and server.

- `HttpClient.sendInterop` sends an interop request and converts the response.
- `HttpClientResponse.toInterop` wraps a native response without reading its body.
- `HttpServer.listenInterop` serves requests using an interop handler.

The adapters preserve native client settings and server stream behavior.
Response bodies are single-subscription streams: consume or cancel them to
release connection resources. Converted headers use a new map but share the
native header value lists.

An optional `responseConverter` replaces the default `toInterop()` conversion.
It can return a response synchronously or asynchronously and provides access to
native metadata, such as compression state:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listenInterop(
    (_) async => Response(200, Body.text('Hello!'), Headers()),
  );

  final client = HttpClient();
  try {
    final response = await client.sendInterop(
      Request(
        'GET',
        Uri.parse('http://127.0.0.1:${server.port}/'),
        Body.empty(),
        Headers(),
      ),
      responseConverter: (native) {
        final response = native.toInterop();
        response.context['compressionState'] = native.compressionState;
        return response;
      },
    );

    print(response.context['compressionState']);
    print(await response.body.decode(utf8));
  } finally {
    client.close(force: true);
    await server.close(force: true);
  }
}
```

Dart's automatic decompression preserves the original `Content-Encoding` and
`Content-Length` headers. The default conversion retains that behavior; use
`responseConverter` to inspect native compression state or apply another policy.
If a converter starts reading the native body, it owns that subscription and must
complete or cancel it on failure. If it consumes the body successfully, it must
return a replacement body.

[Interop]: https://pub.dev/packages/http_interop
