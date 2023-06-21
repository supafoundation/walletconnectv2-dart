import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:supa_wc_v2/model/SupaWalletConnectParam.dart';
import 'package:supa_wc_v2/supa_wc_v2.dart';

void main() {
  runApp(MaterialApp(
      home: MyApp()
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _supaWcV2Plugin = SupaWcV2(
      SupaWalletConnectParam(
          "cff05f7178b7c4b32d665fb40ebab547",
          "Test app",
          "Test App",
          "https://supacharge.io",
          ["https://play-lh.googleusercontent.com/i-Nj5MVnu6Dek0z2x3a2z7Ly1G3nbkIq3uRtgH4w1XcLpsVazk-mImNbsF6_qdf2upQ=w480-h960-rw"]),
          (supaSession){

  });

  String signRes = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await SupaWcV2.instance.initWalletConnectClient();
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      // platformVersion =
      //     await _supaWcV2Plugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: SupaWcV2.instance.supaSessionData == null ?TextButton(
            onPressed: () async{
              showDialog(context: context, builder: (ctx){
                return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Web3ModelView(SupaWcV2.instance));
              });
            },
            child: Text("Connect"),
          ):Padding(padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Has session ${SupaWcV2.instance.supaSessionData!.sessionData.topic}"),
                TextButton(
                  onPressed: ()async{
                    signRes = await SupaWcV2.instance.personalSign("ABC");
                    setState(() {

                    });
                  },
                  child: Text("Sign"),
                ),
                signRes!=""?Text("Sign res ${signRes}"):Container(),

                TextButton(
                  onPressed: (){
                    showDialog(context: context, builder: (ctx){
                      return Dialog(
                          backgroundColor: Colors.transparent,
                          child: Web3ModelView(SupaWcV2.instance));
                    });
                  },
                  child: Text("Connect"),
                ),

                TextButton(
                  onPressed: ()async{
                    await SupaWcV2.instance.removeSession();
                    SupaWcV2.instance.supaSessionData = null;
                    await SupaWcV2.instance.initWalletConnectClient();
                    setState(() {

                    });
                  },
                  child: Text("Disconnect"),
                )
              ],
            ))
      ),
    );
  }
}
