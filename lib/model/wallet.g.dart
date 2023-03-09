// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallet _$WalletFromJson(Map json) => Wallet(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      homepage: json['homepage'] as String?,
      chains:
          (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
      app: WalletAppLinks.fromJson(
          Map<String, dynamic>.from(json['app'] as Map)),
      mobile: WalletLinks.fromJson(
          Map<String, dynamic>.from(json['mobile'] as Map)),
      desktop: WalletLinks.fromJson(
          Map<String, dynamic>.from(json['desktop'] as Map)),
      metadata: WalletMetadata.fromJson(
          Map<String, dynamic>.from(json['metadata'] as Map)),
    );

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'homepage': instance.homepage,
      'chains': instance.chains,
      'app': instance.app.toJson(),
      'mobile': instance.mobile.toJson(),
      'desktop': instance.desktop.toJson(),
      'metadata': instance.metadata.toJson(),
    };

WalletLinks _$WalletLinksFromJson(Map<String, dynamic> json) => WalletLinks(
      native: json['native'] as String?,
      universal: json['universal'] as String?,
    );

Map<String, dynamic> _$WalletLinksToJson(WalletLinks instance) =>
    <String, dynamic>{
      'native': instance.native,
      'universal': instance.universal,
    };

WalletAppLinks _$WalletAppLinksFromJson(Map<String, dynamic> json) =>
    WalletAppLinks(
      browser: json['browser'] as String?,
      ios: json['ios'] as String?,
      android: json['android'] as String?,
    );

Map<String, dynamic> _$WalletAppLinksToJson(WalletAppLinks instance) =>
    <String, dynamic>{
      'browser': instance.browser,
      'ios': instance.ios,
      'android': instance.android,
    };

WalletMetadata _$WalletMetadataFromJson(Map<String, dynamic> json) =>
    WalletMetadata(
      shortName: json['shortName'] as String?,
    );

Map<String, dynamic> _$WalletMetadataToJson(WalletMetadata instance) =>
    <String, dynamic>{
      'shortName': instance.shortName,
    };
