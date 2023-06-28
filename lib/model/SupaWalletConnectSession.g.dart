// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SupaWalletConnectSession.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupaWalletConnectSession _$SupaWalletConnectSessionFromJson(Map json) =>
    SupaWalletConnectSession(
      json['uri'] as String,
      SessionData.fromJson(
          Map<String, dynamic>.from(json['sessionData'] as Map)),
      json['keyChainValue'] as String,
      // PairingInfo.fromJson(
      //     Map<String, dynamic>.from(json['pairingInfo'] as Map)),
      wallet: json['wallet'] == null
          ? null
          : Wallet.fromJson(Map<String, dynamic>.from(json['wallet'] as Map)),
    );

Map<String, dynamic> _$SupaWalletConnectSessionToJson(
        SupaWalletConnectSession instance) =>
    <String, dynamic>{
      'sessionData': instance.sessionData.toJson(),
      'keyChainValue': instance.keyChainValue,
      // 'pairingInfo': instance.pairingInfo.toJson(),
      'uri': instance.uri,
      'wallet': instance.wallet?.toJson(),
    };
