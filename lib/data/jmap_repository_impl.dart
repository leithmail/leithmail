import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/repositories/jmap_repository.dart';
import 'package:leithmail/domain/entities/jmap_session.dart';

class JmapRepositoryImpl implements JmapRepository {
  final http.Client _httpClient;

  const JmapRepositoryImpl(this._httpClient);

  @override
  Future<JmapSession> fetchSession({
    required Uri jmapSessionEndpoint,
    required Credentials credentials,
  }) async {
    final http.Response response;

    try {
      response = await _httpClient.get(
        jmapSessionEndpoint,
        headers: {
          'Authorization': credentials.toAuthorizationHeader(),
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      throw JmapRepositoryException(
        kind: JmapRepositoryExceptionKind.networkError,
        message: 'Failed to reach JMAP session endpoint: $e',
      );
    }

    if (response.statusCode == 401) {
      throw JmapRepositoryException(
        kind: JmapRepositoryExceptionKind.unauthorized,
        message:
            'JMAP session request rejected: invalid or expired credentials.',
      );
    }

    if (response.statusCode != 200) {
      throw JmapRepositoryException(
        kind: JmapRepositoryExceptionKind.serverError,
        message:
            'JMAP session request failed with status ${response.statusCode}.',
      );
    }

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return JmapSession(
        apiUrl: Uri.parse(json['apiUrl'] as String),
        downloadUrl: Uri.parse(json['downloadUrl'] as String),
        uploadUrl: Uri.parse(json['uploadUrl'] as String),
        eventSourceUrl: Uri.parse(json['eventSourceUrl'] as String),
        sessionUrl: jmapSessionEndpoint,
      );
    } on FormatException catch (e) {
      throw JmapRepositoryException(
        kind: JmapRepositoryExceptionKind.parseError,
        message: 'Failed to parse JMAP session response: $e',
      );
    }
  }
}
