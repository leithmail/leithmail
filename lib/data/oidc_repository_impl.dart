import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/repositories/oidc_repository.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';

class OidcRepositoryImpl implements OidcRepository {
  final http.Client _httpClient;
  final String _redirectUri;
  final String _customUriScheme;
  final String _defaultClientId;

  OidcRepositoryImpl({
    required http.Client httpClient,
    required String redirectUri,
    required String customUriScheme,
    required String defaultClientId,
  }) : _httpClient = httpClient,
       _redirectUri = redirectUri,
       _customUriScheme = customUriScheme,
       _defaultClientId = defaultClientId;

  @override
  Future<OidcCredentials> discoverProvider(String domain) async {
    final url = Uri.https(domain, '/.well-known/openid-configuration');
    Log.info('[$runtimeType] discovering OIDC provider at $url');

    final response = await _httpClient.get(url);
    Log.debug('[$runtimeType] discovery response: ${response.statusCode}');

    if (response.statusCode == 404) {
      throw OidcDiscoveryException('No OIDC provider found for $domain');
    }
    if (response.statusCode != 200) {
      throw OidcDiscoveryException(
        'Unexpected status ${response.statusCode} from $url',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final credentials = OidcCredentials(
      issuer: Uri.parse(json['issuer'] as String),
      authorizationEndpoint: Uri.parse(
        json['authorization_endpoint'] as String,
      ),
      tokenEndpoint: Uri.parse(json['token_endpoint'] as String),
      clientId: _defaultClientId,
    );
    Log.info(
      '[$runtimeType] discovered provider: issuer=${credentials.issuer}',
    );
    return credentials;
  }

  @override
  Future<OidcCredentials> authenticate(
    OidcCredentials credentials, {
    String? loginHint,
  }) async {
    Log.info(
      '[$runtimeType] starting PKCE auth flow: issuer=${credentials.issuer}, clientId=${credentials.clientId}, redirectUri=$_redirectUri',
    );

    final client = OAuth2Client(
      authorizeUrl: credentials.authorizationEndpoint.toString(),
      tokenUrl: credentials.tokenEndpoint.toString(),
      redirectUri: _redirectUri,
      customUriScheme: _customUriScheme,
    );

    final response = await client.getTokenWithAuthCodeFlow(
      clientId: credentials.clientId,
      scopes: ['openid', 'email', 'offline_access'],
      httpClient: _httpClient,
      authCodeParams: loginHint != null ? {'login_hint': loginHint} : null,
    );
    Log.info('[$runtimeType] auth flow completed, mapping token response');

    final credentialsWithTokens = credentials.copyWithTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiry: response.expirationDate,
    );
    Log.info(
      '[$runtimeType] authenticated successfully, token expires at ${credentialsWithTokens.expiry}',
    );
    return credentialsWithTokens;
  }

  @override
  Future<OidcCredentials> refresh(OidcCredentials credentials) async {
    final refreshToken = credentials.refreshToken;

    if (!credentials.canBeRefreshed || refreshToken == null) {
      Log.error('[$runtimeType] cannot refresh token');
      throw OidcAuthException('Cannot refresh token');
    }

    if (!credentials.isExpired) {
      Log.warning('[$runtimeType] refreshing token before expiration');
    }

    Log.info(
      '[$runtimeType] refreshing token: clientId=${credentials.clientId}, endpoint=${credentials.tokenEndpoint}',
    );

    final client = OAuth2Client(
      authorizeUrl: credentials.authorizationEndpoint.toString(),
      tokenUrl: credentials.tokenEndpoint.toString(),
      redirectUri: _redirectUri,
      customUriScheme: _customUriScheme,
    );

    final AccessTokenResponse response;
    try {
      response = await client.refreshToken(
        refreshToken,
        clientId: credentials.clientId,
        httpClient: _httpClient,
      );
    } catch (err) {
      Log.error('[$runtimeType] unable to refresh token: $err');
      throw OidcAuthException('Unable to refresh token');
    }
    Log.info('[$runtimeType] token refresh completed');

    final fresh = credentials.copyWithTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiry: response.expirationDate,
    );
    Log.info('[$runtimeType] new token expires at ${fresh.expiry}');
    return fresh;
  }
}
