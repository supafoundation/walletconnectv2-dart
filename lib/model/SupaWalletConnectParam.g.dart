// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SupaWalletConnectParam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupaWalletConnectParam _$SupaWalletConnectParamFromJson(Map json) =>
    SupaWalletConnectParam(
      json['projectId'] as String,
      json['name'] as String,
      json['description'] as String,
      json['url'] as String,
      (json['icons'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SupaWalletConnectParamToJson(
        SupaWalletConnectParam instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'icons': instance.icons,
    };
