
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
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
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
      await signClient.connect(
        requiredNamespaces:  {
          'eip155': RequiredNamespace(
            chains: ['eip155:1'], // Ethereum chain
            methods: ['eth_sign','personal_sign'],
            events: ["chainChanged",
              "accountsChanged"], // Requestable Methods
          ),
        },
        //   optionalNamespaces: {
        // 'eip155': RequiredNamespace(
        //   chains: ['eip155:1', 'eip155:250', 'eip155:137', 'eip155:56'], // Ethereum chain
        //   methods: ['eth_sign','personal_sign'],
        //   events: ["chainChanged",
        //     "accountsChanged"], // Requestable Methods
        // ),
        // }
      );
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

  void openWallet(String wcUri) {
    if (Utils.isAndroid) {
      // print("URI ${uri}");

      launchUrl(Uri.parse(uri));

    } else {
      if (supaSessionData?.wallet == null) {
        Utils.iosLaunch(wallet: wallet!, uri: wcUri);
      } else{
        Utils.iosLaunch(wallet: supaSessionData!.wallet!, uri: wcUri);
      }
    }
  }

  // Future<void> launchRedirect({
  //   Uri? nativeUri,
  //   Uri? universalUri,
  // }) async {
  //
  //   // Launch the link
  //   if (nativeUri != null && await canLaunchUrl(nativeUri)) {
  //     print(
  //       'Navigating deep links. Launching native URI.',
  //     );
  //     try {
  //       await launchUrl(
  //         nativeUri,
  //         mode: LaunchMode.externalApplication,
  //       );
  //     } catch (e) {
  //       print(
  //         'Navigating deep links. Launching native failed, launching universal URI.',
  //       );
  //       // Fallback to universal link
  //       if (universalUri != null && await canLaunchUrl(universalUri)) {
  //         await launchUrl(
  //           universalUri,
  //           mode: LaunchMode.externalApplication,
  //         );
  //       } else {
  //         throw Exception('Unable to open the wallet');
  //       }
  //     }
  //   } else if (universalUri != null && await canLaunchUrl(universalUri)) {
  //     print(
  //       'Navigating deep links. Launching universal URI.',
  //     );
  //     await launchUrl(
  //       universalUri,
  //       mode: LaunchMode.externalApplication,
  //     );
  //   } else {
  //     throw Exception('Unable to open the wallet');
  //   }
  // }

  // Redirect? _constructRedirect(SessionData? session) {
  //   if (session == null) {
  //     return null;
  //   }
  //
  //   final Redirect? sessionRedirect = session?.peer.metadata.redirect;
  //   final Redirect? explorerRedirect = Redirect(
  //     native: "trust://",
  //       universal: "https://link.trustwallet.com"
  //   );
  //
  //   if (sessionRedirect == null && explorerRedirect == null) {
  //     return null;
  //   }
  //
  //   // Combine the redirect data from the session and the explorer API.
  //   // The explorer API is the source of truth.
  //   return Redirect(
  //     native: explorerRedirect?.native ?? sessionRedirect?.native,
  //     universal: explorerRedirect?.universal ?? sessionRedirect?.universal,
  //   );
  // }



  void connect() {
    openWallet(uri);
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
        await signClient.sessions.set(supaSessionData!.sessionData.topic, supaSessionData!.sessionData);
      }
      if (!signClient.signEngine.getActiveSessions().containsKey(supaSessionData!.sessionData.topic)) {
        await signClient.signEngine.sessions.set(supaSessionData!.sessionData.topic, supaSessionData!.sessionData);
      }
      print("Session data ${signClient.getActiveSessions().keys.toList()}. ${signClient.signEngine.getActiveSessions().keys.toList()}. ${signClient.signEngine.sessions.has(supaSessionData!.sessionData.topic)}");
      openWallet("");
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

        if (Utils.isAndroid) {

          try{
            signClient.request(
              topic: supaSessionData!.sessionData.topic,
              chainId: 'eip155:1',
              request: SessionRequestParams(
                method: 'personal_sign',
                params: [message, getWalletAddress()],
              ),
            );
          }catch(e) {
            print("Err $e");
          }
        }
        print("Start ${DateTime.now().millisecondsSinceEpoch/1000}");
        await Future.delayed(Duration(milliseconds: 10000));
        print("After 5s ${DateTime.now().millisecondsSinceEpoch/1000}");
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
        uri = "";
        wallet = null;
        supaSessionData = null;
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
