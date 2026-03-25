import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/domain/entities/oidc_provider_metadata.dart';
import 'package:leithmail/domain/repositories/oidc_repository.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';

class OidcRepositoryImpl implements OidcRepository {
  final http.Client _httpClient;
  final String _redirectUri;
  final String _customUriScheme;
  final String _defaultClientId;

  String get _tag => runtimeType.toString();

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
  Future<OidcProviderMetadata?> discoverProvider(EmailAddress email) async {
    final url = Uri.https(email.domain, '/.well-known/openid-configuration');
    Log.info('[$_tag] discovering OIDC provider at $url');

    final response = await _httpClient.get(url);
    Log.debug('[$_tag] discovery response: ${response.statusCode}');

    if (response.statusCode == 404) {
      Log.info('[$_tag] no OIDC provider found for ${email.domain}');
      return null;
    }
    if (response.statusCode != 200) {
      throw OidcDiscoveryException(
        'Unexpected status ${response.statusCode} from $url',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final metadata = OidcProviderMetadata(
      issuer: Uri.parse(json['issuer'] as String),
      authorizationEndpoint: Uri.parse(
        json['authorization_endpoint'] as String,
      ),
      tokenEndpoint: Uri.parse(json['token_endpoint'] as String),
    );
    Log.info('[$_tag] discovered provider: issuer=${metadata.issuer}');
    return metadata;
  }

  @override
  Future<CredentialsOidc> authenticate(
    OidcProviderMetadata metadata,
    EmailAddress email,
  ) async {
    final clientId = metadata.clientId ?? _defaultClientId;
    Log.info(
      '[$_tag] starting PKCE auth flow: issuer=${metadata.issuer}, clientId=$clientId',
    );

    final client = OAuth2Client(
      authorizeUrl: metadata.authorizationEndpoint.toString(),
      tokenUrl: metadata.tokenEndpoint.toString(),
      redirectUri: _redirectUri,
      customUriScheme: _customUriScheme,
    );

    final response = await client.getTokenWithAuthCodeFlow(
      clientId: clientId,
      scopes: ['openid', 'email', 'offline_access'],
      httpClient: _httpClient,
      authCodeParams: {'login_hint': email.value},
    );
    Log.info('[$_tag] auth flow completed, mapping token response');

    final credentials = _credentialsFromResponse(
      response,
      metadata.tokenEndpoint,
      clientId,
    );
    Log.info(
      '[$_tag] authenticated successfully, token expires at ${credentials.expiry}',
    );
    return credentials;
  }

  @override
  Future<CredentialsOidc> refresh(CredentialsOidc credentials) async {
    Log.info(
      '[$_tag] refreshing token: clientId=${credentials.clientId}, endpoint=${credentials.tokenEndpoint}',
    );

    final client = OAuth2Client(
      authorizeUrl: '',
      tokenUrl: credentials.tokenEndpoint.toString(),
      redirectUri: _redirectUri,
      customUriScheme: _customUriScheme,
    );

    final current = AccessTokenResponse.fromMap({
      'access_token': credentials.accessToken,
      'refresh_token': credentials.refreshToken,
    });

    final response = await client.refreshToken(
      current.refreshToken ?? '',
      clientId: credentials.clientId,
      httpClient: _httpClient,
    );
    Log.info('[$_tag] token refresh completed');

    final fresh = _credentialsFromResponse(
      response,
      credentials.tokenEndpoint,
      credentials.clientId,
    );
    Log.info('[$_tag] new token expires at ${fresh.expiry}');
    return fresh;
  }

  CredentialsOidc _credentialsFromResponse(
    AccessTokenResponse response,
    Uri tokenEndpoint,
    String clientId,
  ) {
    final accessToken = response.accessToken;
    final refreshToken = response.refreshToken;
    final expiry = response.expirationDate;

    if (accessToken == null || refreshToken == null || expiry == null) {
      Log.error(
        '[$_tag] incomplete token response',
        'accessToken=${accessToken != null}, refreshToken=${refreshToken != null}, expiry=${expiry != null}',
      );
      throw OidcAuthException(
        'Incomplete token response: missing accessToken, refreshToken, or expiry',
      );
    }

    return CredentialsOidc(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiry: expiry,
      tokenEndpoint: tokenEndpoint,
      clientId: clientId,
    );
  }
}
