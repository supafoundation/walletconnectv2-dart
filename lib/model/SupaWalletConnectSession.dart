import 'package:json_annotation/json_annotation.dart';
import 'package:supa_wc_v2/model/wallet.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';

part 'SupaWalletConnectSession.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class SupaWalletConnectSession {
  SupaWalletConnectSession(
      this.uri, this.sessionData, this.keyChainValue, this.pairingInfo,
      {this.wallet});

  SessionData sessionData;

  String keyChainValue;

  PairingInfo pairingInfo;

  String uri;

  Wallet? wallet;

  factory SupaWalletConnectSession.fromJson(Map<String, dynamic> json) =>
      _$SupaWalletConnectSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SupaWalletConnectSessionToJson(this);

  int getExpiredTime() {
    return sessionData.expiry;
  }

  String getWalletAddress() {
    var walletAdress = "";
    sessionData.namespaces.forEach((key, value) {
      var listSplit = value.accounts.last.split(":");
      if (listSplit.length == 3) {
        walletAdress = listSplit[2];
      }
    });
    return walletAdress;
  }
}
