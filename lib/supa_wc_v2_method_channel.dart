import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'supa_wc_v2_platform_interface.dart';

/// An implementation of [SupaWcV2Platform] that uses method channels.
class MethodChannelSupaWcV2 extends SupaWcV2Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('supa_wc_v2');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
