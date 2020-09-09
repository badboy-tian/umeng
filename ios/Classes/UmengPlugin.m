#import "UmengPlugin.h"
#import <UMCommon/UMCommon.h>
#import <UMCommon/MobClick.h>

@implementation UmengPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"kaige.com/umeng_analytics"
            binaryMessenger:[registrar messenger]];
  UmengPlugin* instance = [[UmengPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
      [self init:call result:result];
  }else if([@"pageStart" isEqualToString:call.method]){
      [self pageStart:call result:result];
  }else if([@"pageEnd" isEqualToString:call.method]){
      [self pageEnd:call result:result];
  }else if([@"onEvent" isEqualToString:call.method]){
      [self onEvent:call result:result];
  }else if([@"onProfileSignIn" isEqualToString:call.method]){
      [self onProfileSignIn:call result:result];
  }else if([@"onProfileSignOff" isEqualToString:call.method]){
      [self onProfileSignOff:call result:result];
  }else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)init:(FlutterMethodCall*)call result:(FlutterResult)result{
    [MobClick setCrashReportEnabled:call.arguments[@"catchUncaughtExceptionsEnabled"]];
    NSString* pageCollectMode = call.arguments[@"pageCollectMode"];
    if([@"MANUAL" isEqualToString:pageCollectMode]){
        [MobClick setAutoPageEnabled:NO];
    }else{
        [MobClick setAutoPageEnabled:YES];
    }
    [UMConfigure setLogEnabled:call.arguments[@"logEnabled"]];
    [UMConfigure setEncryptEnabled:call.arguments[@"encryptEnabled"]];
    [UMConfigure initWithAppkey:call.arguments[@"iosKey"] channel:call.arguments[@"channel"]];
    result([NSNumber numberWithBool:YES]);
}

- (void)pageStart:(FlutterMethodCall*)call result:(FlutterResult)result{
    [MobClick beginLogPageView:call.arguments[@"widget"]];
    result([NSNumber numberWithBool:YES]);
}
- (void)pageEnd:(FlutterMethodCall*)call result:(FlutterResult)result{
    [MobClick endLogPageView:call.arguments[@"widget"]];
    result([NSNumber numberWithBool:YES]);
}
- (void)onEvent:(FlutterMethodCall*)call result:(FlutterResult)result{
    [MobClick event:call.arguments[@"eventId"] attributes:call.arguments[@"properties"]];
    result([NSNumber numberWithBool:YES]);
}
- (void)onProfileSignIn:(FlutterMethodCall*)call result:(FlutterResult)result{
    [MobClick profileSignInWithPUID:call.arguments[@"id"] provider:call.arguments[@"provider"]];
    result([NSNumber numberWithBool:YES]);
}
- (void)onProfileSignOff:(FlutterMethodCall*)call result:(FlutterResult)result{
    [MobClick profileSignOff];
    result([NSNumber numberWithBool:YES]);
}

@end
