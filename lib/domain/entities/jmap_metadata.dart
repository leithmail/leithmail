import 'package:json_annotation/json_annotation.dart';

part 'jmap_metadata.g.dart';

@JsonSerializable()
class JmapMetadata {
  final Uri apiUrl;
  final Uri downloadUrl;
  final Uri uploadUrl;
  final Uri eventSourceUrl;

  const JmapMetadata({
    required this.apiUrl,
    required this.downloadUrl,
    required this.uploadUrl,
    required this.eventSourceUrl,
  });

  factory JmapMetadata.fromJson(Map<String, dynamic> json) =>
      _$JmapMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$JmapMetadataToJson(this);
}
