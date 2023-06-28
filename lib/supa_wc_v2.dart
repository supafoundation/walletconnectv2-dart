
import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supa_wc_v2/model/SupaWalletConnectParam.dart';
import 'package:supa_wc_v2/model/SupaWalletConnectSession.dart';
import 'package:supa_wc_v2/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';
import 'package:walletconnect_flutter_v2/apis/models/basic_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/json_rpc_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/proposal_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/sign_client.dart';
import 'package:walletconnect_flutter_v2/apis/utils/errors.dart';
import 'package:walletconnect_flutter_v2/apis/web3app/web3app.dart';

import 'model/wallet.dart';

export 'view/Web3ModalView.dart';

class SupaWcV2 {
  late Web3App signClient;
  FlutterSecureStorage storage = FlutterSecureStorage(aOptions: const AndroidOptions(
    encryptedSharedPreferences: true,
  ));

  SupaWalletConnectSession? supaSessionData;
  Function(SupaWalletConnectSession)? connectCallBack;
  SupaWalletConnectParam? param;


  bool initialized = false;
  bool isFirstTimeConnect = false;
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
    if (initialized) {
      return;
    }

    final paringMeta = PairingMetadata(
      name: param!.name,
      description: param!.description,
      url:  param!.url,
      icons: param!.icons,
    );

    var sessionStoreStr = await storage.read(key: sessionKeyStore);

    if (sessionStoreStr != null) {
      // da co session, check expired
      print("Has session $sessionStoreStr");
      isFirstTimeConnect = false;
      supaSessionData = SupaWalletConnectSession.fromJson(Map<String, dynamic>.from(jsonDecode(sessionStoreStr)));
      if (supaSessionData!.getExpiredTime() > DateTime.now().millisecondsSinceEpoch/1000) {
        // init
        uri = supaSessionData!.uri;
        signClient = await Web3App.createInstance(projectId: param!.projectId,
            metadata: paringMeta,
            relayUrl: 'wss://relay.walletconnect.com');
        await signClient.init();
        // signClient.core.crypto.keyChain!.set(supaSessionData!.sessionData.topic, supaSessionData!.keyChainValue);
        // signClient.pairings.set(supaSessionData!.pairingInfo.topic, supaSessionData!.pairingInfo);
        // signClient.engine.sessions.set(supaSessionData!.sessionData.topic, supaSessionData!.sessionData);
        // await signClient.engine.core.pairing.updateMetadata(
        //   topic: "${supaSessionData!.pairingInfo.topic}",
        //   metadata: supaSessionData!.sessionData.peer.metadata,
        // );
        // await signClient.engine.core.pairing.activate(topic: supaSessionData!.sessionData.topic);
        // await signClient.core.relayClient.subscribe(topic: supaSessionData!.sessionData.topic);
        initialized = true;
      }
    }

    if (!initialized) {
      signClient = await Web3App.createInstance(
          metadata: paringMeta,
          projectId: param!.projectId,
          relayUrl: 'wss://relay.walletconnect.com'
      );


      print("Start connect wcv2");
      ConnectResponse resp =
      await signClient.connect(requiredNamespaces:  {
        'eip155': RequiredNamespace(
          chains: ['eip155:1'], // Ethereum chain
          methods: ['eth_sign','personal_sign'],
          events: ["chainChanged",
            "accountsChanged"], // Requestable Methods
        ),
      });
      print("Done connect wcv2");
      // Uri? uri = resp.uri;
      print("URI $uri. ${uri!.toString()}");
      uri = resp.uri.toString();

      var session = await resp.session.future;
      // var mapSessionKeyChain = signClient.core.storage.get(signClient.core.crypto.keyChain!.storageKey);
      // var pairingInfo = signClient.pairings.getAll().last;
      var mapSessionKeyChain = {};
      // var pairingInfo = PairingInfo(topic: "", expiry: 1, relay: "", active: active);
      supaSessionData = SupaWalletConnectSession(uri, session, mapSessionKeyChain[session.topic]??"", wallet: wallet);
      print("Supa Session ${jsonEncode(supaSessionData!.toJson())}");
      if (this.connectCallBack != null) {
        this.connectCallBack!(supaSessionData!);
      }
      storage.write(key: sessionKeyStore, value: jsonEncode(supaSessionData!.toJson()));

      isFirstTimeConnect = true;
      initialized = true;
    }

  }

  void openWallet() {
    if (Utils.isAndroid) {
      launchUrl(Uri.parse(uri));
    } else {
     if (supaSessionData?.wallet == null) {
       Utils.iosLaunch(wallet: wallet!, uri: uri);
     } else{
       Utils.iosLaunch(wallet: supaSessionData!.wallet!, uri: uri);
     }
    }
  }

  void connect() {
    openWallet();
  }

  String getWalletAddress() {
    var walletAdress = "";
    if (initialized) {
      walletAdress = supaSessionData!.getWalletAddress();
    }
    return walletAdress;
  }

  Future<String> personalSign(String message) async{
    if (initialized) {
      var activeSession = signClient.getActiveSessions();
      if (!activeSession.containsKey(supaSessionData!.sessionData.topic)) {
        signClient.sessions.set(supaSessionData!.sessionData.topic, supaSessionData!.sessionData)
      }
      openWallet();
      if (isFirstTimeConnect) {
        isFirstTimeConnect = false;
        // signClient.request(
        //   topic: supaSessionData!.sessionData.topic,
        //   chainId: 'eip155:1',
        //   request: SessionRequestParams(
        //     method: 'personal_sign',
        //     params: [message, getWalletAddress()],
        //   ),
        // );
        // await signClient.signEngine.sessions.set(supaSessionData!.sessionData.topic, supaSessionData!.sessionData);

        await Future.delayed(Duration(milliseconds: 5000));
        print("After 5s");
      }

      var signResponse = await signClient.request(
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
    try {
      if (initialized) {
        initialized = false;
        isFirstTimeConnect = false;
        await storage.delete(key: sessionKeyStore);
        var data = signClient.getActiveSessions();
        data.forEach((key, value) async{
          await signClient.disconnectSession(
              topic: key,
              reason: Errors.getSdkError(
                Errors.USER_DISCONNECTED,
              ));
        });
        // await signClient.disconnectSession(topic: supaSessionData!.sessionData.topic, reason: WalletConnectError(code: 6000, message: "User disconnected."));
      }
    } catch(e){
      print("Remove session error $e");
    }
  }
}
