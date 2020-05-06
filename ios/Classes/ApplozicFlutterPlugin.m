#import "ApplozicFlutterPlugin.h"
#if __has_include(<applozic_flutter/applozic_flutter-Swift.h>)
#import <applozic_flutter/applozic_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "applozic_flutter-Swift.h"
#endif

@implementation ApplozicFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApplozicFlutterPlugin registerWithRegistrar:registrar];
}
@end
