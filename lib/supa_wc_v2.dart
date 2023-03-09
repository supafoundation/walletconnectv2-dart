
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supa_wc_v2/model/SupaWalletConnectParam.dart';
import 'package:supa_wc_v2/model/SupaWalletConnectSession.dart';
import 'package:supa_wc_v2/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/json_rpc_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/proposal_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/sign_client.dart';

import 'model/wallet.dart';

export 'view/Web3ModalView.dart';

class SupaWcV2 {
  late SignClient signClient;
  late FlutterSecureStorage storage;
  SupaWalletConnectSession? supaSessionData;
  Function(SupaWalletConnectSession)? connectCallBack;
  SupaWalletConnectParam? param;


  bool initialized = false;
  String sessionKeyStore = "supawcv2_session";
  // final String projectId = "62a566d93c3dde42fff6dc683ed2c9d4";
  String uri = "";

  Wallet? wallet;

  static SupaWcV2 get instance => _instance;

  static final SupaWcV2 _instance =
  SupaWcV2._internal();

  factory SupaWcV2(SupaWalletConnectParam param, Function(SupaWalletConnectSession) connectCallBack) {
    _instance.connectCallBack = connectCallBack;
    _instance.param = param;
    return _instance;
  }

  SupaWcV2._internal() {
    // initialization logic
    // check neu co session thi load session va check expired date

    // neu khong co hoac expired thi tao session moi
  }

  Future<void> initWalletConnectClient() async{
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

    final paringMeta = PairingMetadata(
      name: param!.name,
      description: param!.description,
      url:  param!.url,
      icons: param!.icons,
    );


    storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

    var sessionStoreStr = await storage.read(key: sessionKeyStore);

    if (sessionStoreStr != null) {
      // da co session, check expired
      print("Has session $sessionStoreStr");
      supaSessionData = SupaWalletConnectSession.fromJson(Map<String, dynamic>.from(jsonDecode(sessionStoreStr)));
      if (supaSessionData!.getExpiredTime() > DateTime.now().millisecondsSinceEpoch/1000) {
        // init
        uri = supaSessionData!.uri;
        signClient = await SignClient.createInstance(projectId: param!.projectId,
            metadata: paringMeta,
            relayUrl: 'wss://relay.walletconnect.com');
        await signClient.init();
        signClient.core.crypto.keyChain!.set(supaSessionData!.sessionData.topic, supaSessionData!.keyChainValue);
        signClient.pairings.set(supaSessionData!.pairingInfo.topic, supaSessionData!.pairingInfo);
        signClient.engine.sessions.set(supaSessionData!.sessionData.topic, supaSessionData!.sessionData);
        await signClient.engine.core.pairing.updateMetadata(
          topic: "${supaSessionData!.pairingInfo.topic}",
          metadata: supaSessionData!.sessionData.peer.metadata,
        );
        await signClient.engine.core.pairing.activate(topic: supaSessionData!.sessionData.topic);
        await signClient.core.relayClient.subscribe(topic: supaSessionData!.sessionData.topic);
        initialized = true;
      }
    }

    if (!initialized) {
      signClient = await SignClient.createInstance(
          metadata: paringMeta,
          projectId: param!.projectId,
          relayUrl: 'wss://relay.walletconnect.com'
      );


      ConnectResponse resp =
      await signClient.connect(requiredNamespaces:  {
        'eip155': RequiredNamespace(
          chains: ['eip155:1'], // Ethereum chain
          methods: ['eth_sign','personal_sign'],
          events: ["personal_sign", 'eth_sign'], // Requestable Methods
        ),
      });
      // Uri? uri = resp.uri;
      print("URI $uri. ${uri!.toString()}");
      uri = resp.uri.toString();

      var session = await resp.session.future;
      var mapSessionKeyChain = signClient.core.storage.get(signClient.core.crypto.keyChain!.storageKey);
      var pairingInfo = signClient.pairings.getAll().last;
      supaSessionData = SupaWalletConnectSession(uri, session, mapSessionKeyChain[session.topic]??"", pairingInfo, wallet: wallet);
      print("Supa Session ${jsonEncode(supaSessionData!.toJson())}");
      if (this.connectCallBack != null) {
        this.connectCallBack!(supaSessionData!);
      }
      storage.write(key: sessionKeyStore, value: jsonEncode(supaSessionData!.toJson()));
      initialized = true;
    }

  }

  void openWallet() {
    if (Utils.isAndroid) {
      launchUrl(Uri.parse(uri));
    } else {
     Utils.iosLaunch(wallet: supaSessionData!.wallet!, uri: uri);
    }
  }

  void connect() {
    openWallet();
  }

  String getWalletAddress() {
    var walletAdress = "";
    if (initialized) {
      supaSessionData!.sessionData.namespaces.forEach((key, value) {
        var listSplit = value.accounts.last.split(":");
        if (listSplit.length == 3) {
          walletAdress  = listSplit[2];
        }
      });
    }
    return walletAdress;
  }

  Future<String> personalSign(String message) async{
    if (initialized) {
      openWallet();
      final dynamic signResponse = await signClient.request(
        topic: supaSessionData!.sessionData.topic,
        chainId: 'eip155:1',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [message, getWalletAddress()],
        ),
      );
      print("Sign done");
      return signResponse.toString();
    }
    return "";
  }

  Future<void> removeSession() async{
    await storage.delete(key: sessionKeyStore);
  }
}
