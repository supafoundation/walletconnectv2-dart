import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supa_wc_v2/supa_wc_v2.dart';

import '../model/wallet.dart';

class Web3ModelView extends StatefulWidget {

  SupaWcV2 wcClient;

  Web3ModelView(this.wcClient);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Web3ModelViewState();
  }

}

class Web3ModelViewState extends State<Web3ModelView> {


  int _groupValue = 0;

  List<Wallet> listWallet = <Wallet>[];

  @override
  void initState() {
    super.initState();
    // if (!Platform.isAndroid) {
    //   load().then((listWallet) {
    //     listWallet = listWallet;
    //     if (mounted) {
    //       setState(() {
    //
    //       });
    //     }
    //   });
    // }

    load().then((res) {
      listWallet = res;
      print("Load done ${listWallet.length}");
      if (mounted) {
        setState(() {

        });
      }
    });
  }

  Future<List<Wallet>> load() async {
    final walletFile = await DefaultCacheManager()
        .getSingleFile('https://registry.walletconnect.org/data/wallets.json');
    final walletData = jsonDecode(await walletFile.readAsString());

    List<Wallet> listData = walletData.entries
        .map<Wallet>((data) => Wallet.fromJson(data.value))
        .toList();
    listData = listData.where((element) => (element.versions??[]).contains("2")).toList();
    return listData;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: MediaQuery.of(context).size.height*2/3,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
        color: Colors.white,),
      padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
      child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              CupertinoSlidingSegmentedControl<int>(
                groupValue: _groupValue,
                onValueChanged: (value) => setState(() {
                  _groupValue = value!;
                }),
                backgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.all(4),
                children: {
                  0: Container(
                    width: 140,
                    height: 25,
                    child: Center(
                        child: Text("Wallet")
                    ),
                  ),
                  1: Container(
                    width: 140,
                    height: 25,
                    child: Center(
                        child: Text("QR Scan")
                    ),
                  ),
                },
              ),
              Expanded(
                  child: Center(
                    child: _buildModalContent(_groupValue),
                  )
              ),
            ],
          )),);
  }

  Widget _buildModalContent(int type) {
   if (type == 0) {
     if (Platform.isAndroid) {
       return Container(
           child: GestureDetector(
             onTap: (){
               widget.wcClient.connect();
             },
             child: Container(
                 padding: EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                 decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(8),
                     color: Colors.red
                 ),
                 child: Text(
                     "Connect",
                   style: TextStyle(
                     color: Colors.white
                   ),
                 )
             ),
           )
       );
     } else{
       return listWallet.length == 0? Container(child: const Center(
         child: CupertinoActivityIndicator(),
       )): Container(
         child: ListView.builder(
           itemCount: listWallet.length,
             itemBuilder: (ctx, idx){
               return GestureDetector(
                 onTap: (){
                    widget.wcClient.wallet = listWallet[idx];
                    widget.wcClient.connect();
                 },
                 child: Container(
                   color: Colors.white,
                   padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       Text(
                         "${listWallet[idx].name}"
                       ),
                       Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Image.network("https://registry.walletconnect.org/logo/sm/${listWallet[idx].id}.jpeg",
                             width: 24, height: 24,),
                           Icon(
                             Icons.keyboard_arrow_right,
                             size: 18,
                             color: Colors.black26,
                           )
                         ],
                       )
                     ],
                   ),
                 ),
               );
             }),
       );
     }

   } else{
     return Container(
       padding: EdgeInsets.only(left: 8, right: 8),
       child: QrImage(
         data: "${widget.wcClient.uri}",
         version: QrVersions.auto,
       )
     );
   }
  }

}