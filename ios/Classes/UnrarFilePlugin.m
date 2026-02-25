#import "UnrarFilePlugin.h"
@import UnrarKit;

static inline NSString* NSStringFromBOOL(BOOL aBool) {
    return aBool? @"SUCCESS" : @"FAILURE";
}

@implementation UnrarFilePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"unrar_file"
            binaryMessenger:[registrar messenger]];
  UnrarFilePlugin* instance = [[UnrarFilePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"extractRAR" isEqualToString:call.method]) {
    NSString* file_path = call.arguments[@"file_path"];
    NSString* destination_path = call.arguments[@"destination_path"];
    NSString* password = call.arguments[@"password"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *archiveError = nil;
        URKArchive *archive = [[URKArchive alloc] initWithPath:file_path
                                                         error:&archiveError];
        NSError *error = nil;
        BOOL extractFilesSuccessful = NO;
        
        if (archive) {
            if (archive.isPasswordProtected && password.length != 0) {
                archive.password = password;
            }
            // Việc giải nén tốn thời gian giờ sẽ chạy ngầm, không block UI
            extractFilesSuccessful = [archive extractFilesTo:destination_path overwrite:NO error:&error];
        }
        
        // TRẢ KẾT QUẢ VỀ MAIN THREAD CHO FLUTTER
        dispatch_async(dispatch_get_main_queue(), ^{
            result(NSStringFromBOOL(extractFilesSuccessful));
        });
        
    });
    
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
