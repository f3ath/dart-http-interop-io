## [0.10.0] - 2026-10-23
### Added
- Add an optional synchronous or asynchronous responseConverter to customize native client response conversion.
- Expose HttpClientResponse.toInterop() for converting native responses without consuming their bodies.

### Changed
- Rename HttpClient.handleInterop() to sendInterop() and ServerExt to HttpServerExt; make listenInterop.cancelOnError non-nullable with a default of false.
- Require Dart ^3.13.0 and upgrade http\_interop to ^3.0.0.
- Document client and server usage, body ownership, decompression behavior, shared header value lists, and converter cleanup responsibilities.

### Fixed
- Release client connections after request setup or sending failures and cancel unread response bodies after conversion failures while preserving the original errors.

## [0.9.1] - 2026-10-17
### Changed
- Stream management optimizations

## [0.9.0] - 2024-06-30
### Changed
- Simplified API

## [0.8.0] - 2024-06-30
### Changed
- Bump Interop to v2.0

## [0.7.0] - 2023-10-26
### Changed
- Bumped interop to 1.0.0

## [0.6.0] - 2023-09-07
### Changed
- Bump Interop to 0.8

## [0.5.0] - 2023-08-20
### Changed
- Bump interop

## [0.4.0] - 2023-08-16
### Changed
- Bump dependencies versions

## [0.3.0] - 2023-05-07
### Changed
- Relaxed SDK version to 2.19

## [0.2.0] - 2023-05-07
### Changed
- Bump dependencies

## [0.1.0] - 2023-04-22
### Changed
- Update deps

## [0.0.1] - 2023-04-16
### Added
- Initial release

[0.10.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.9.1...0.10.0
[0.9.1]: https://github.com/f3ath/dart-http-interop-io/compare/0.9.0...0.9.1
[0.9.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.8.0...0.9.0
[0.8.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.7.0...0.8.0
[0.7.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/f3ath/dart-http-interop-io/compare/0.0.1...0.1.0
[0.0.1]: https://github.com/f3ath/dart-http-interop-io/releases/tag/0.0.1
