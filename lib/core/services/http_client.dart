import 'package:http/http.dart' as http;
import 'package:leithmail/core/logging/log.dart';

class HttpClient extends http.BaseClient {
  final http.Client _inner;

  HttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    Log.debug('[$runtimeType] → ${request.method} ${request.url}');
    final response = await _inner.send(request);
    Log.debug(
      '[$runtimeType] ← ${response.statusCode} ${request.method} ${request.url}',
    );
    return response;
  }

  @override
  void close() => _inner.close();
}
