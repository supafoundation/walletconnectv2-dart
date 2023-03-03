import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supa_wc_v2/supa_wc_v2_method_channel.dart';

void main() {
  MethodChannelSupaWcV2 platform = MethodChannelSupaWcV2();
  const MethodChannel channel = MethodChannel('supa_wc_v2');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
