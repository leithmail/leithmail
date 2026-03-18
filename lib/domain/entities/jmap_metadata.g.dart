// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jmap_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JmapMetadata _$JmapMetadataFromJson(Map<String, dynamic> json) => JmapMetadata(
  apiUrl: Uri.parse(json['apiUrl'] as String),
  downloadUrl: Uri.parse(json['downloadUrl'] as String),
  uploadUrl: Uri.parse(json['uploadUrl'] as String),
  eventSourceUrl: Uri.parse(json['eventSourceUrl'] as String),
);

Map<String, dynamic> _$JmapMetadataToJson(JmapMetadata instance) =>
    <String, dynamic>{
      'apiUrl': instance.apiUrl.toString(),
      'downloadUrl': instance.downloadUrl.toString(),
      'uploadUrl': instance.uploadUrl.toString(),
      'eventSourceUrl': instance.eventSourceUrl.toString(),
    };
