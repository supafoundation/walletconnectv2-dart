#import "SupaWcV2Plugin.h"
#if __has_include(<supa_wc_v2/supa_wc_v2-Swift.h>)
#import <supa_wc_v2/supa_wc_v2-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "supa_wc_v2-Swift.h"
#endif

@implementation SupaWcV2Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSupaWcV2Plugin registerWithRegistrar:registrar];
}
@end
