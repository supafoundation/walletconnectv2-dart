import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'supa_wc_v2_method_channel.dart';

abstract class SupaWcV2Platform extends PlatformInterface {
  /// Constructs a SupaWcV2Platform.
  SupaWcV2Platform() : super(token: _token);

  static final Object _token = Object();

  static SupaWcV2Platform _instance = MethodChannelSupaWcV2();

  /// The default instance of [SupaWcV2Platform] to use.
  ///
  /// Defaults to [MethodChannelSupaWcV2].
  static SupaWcV2Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SupaWcV2Platform] when
  /// they register themselves.
  static set instance(SupaWcV2Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
