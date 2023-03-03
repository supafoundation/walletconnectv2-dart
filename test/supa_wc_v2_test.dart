// import 'package:flutter_test/flutter_test.dart';
// import 'package:supa_wc_v2/supa_wc_v2.dart';
// import 'package:supa_wc_v2/supa_wc_v2_platform_interface.dart';
// import 'package:supa_wc_v2/supa_wc_v2_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//
// class MockSupaWcV2Platform
//     with MockPlatformInterfaceMixin
//     implements SupaWcV2Platform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
//
// void main() {
//   final SupaWcV2Platform initialPlatform = SupaWcV2Platform.instance;
//
//   test('$MethodChannelSupaWcV2 is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelSupaWcV2>());
//   });
//
//   test('getPlatformVersion', () async {
//     SupaWcV2 supaWcV2Plugin = SupaWcV2();
//     MockSupaWcV2Platform fakePlatform = MockSupaWcV2Platform();
//     SupaWcV2Platform.instance = fakePlatform;
//
//     expect(await supaWcV2Plugin.getPlatformVersion(), '42');
//   });
// }
