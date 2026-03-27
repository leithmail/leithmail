import 'package:json_annotation/json_annotation.dart';

part 'jmap_session.g.dart';

@JsonSerializable()
class JmapSession {
  final Uri apiUrl;
  final Uri downloadUrl;
  final Uri uploadUrl;
  final Uri eventSourceUrl;
  final Uri sessionUrl;

  const JmapSession({
    required this.apiUrl,
    required this.downloadUrl,
    required this.uploadUrl,
    required this.eventSourceUrl,
    required this.sessionUrl,
  });

  factory JmapSession.mock({
    Uri? apiUrl,
    Uri? downloadUrl,
    Uri? uploadUrl,
    Uri? eventSourceUrl,
    Uri? sessionUrl,
  }) => JmapSession(
    apiUrl: apiUrl ?? Uri.parse('https://mock.jmap.example.com/api'),
    downloadUrl:
        downloadUrl ??
        Uri.parse(
          'https://mock.jmap.example.com/download/{accountId}/{blobId}/{name}',
        ),
    uploadUrl:
        uploadUrl ??
        Uri.parse('https://mock.jmap.example.com/upload/{accountId}/'),
    eventSourceUrl:
        eventSourceUrl ?? Uri.parse('https://mock.jmap.example.com/events'),
    sessionUrl:
        sessionUrl ?? Uri.parse('https://mock.jmap.example.com/session'),
  );

  factory JmapSession.fromJson(Map<String, dynamic> json) =>
      _$JmapSessionFromJson(json);

  Map<String, dynamic> toJson() => _$JmapSessionToJson(this);
}
