//
//  DocRecognize.m

#import "DocRecognize.h"
#import "RecognizeViewController.h"

@interface DocRecognize ()
{
    NSString *callbackId;
}
@end

@implementation DocRecognize

- (void) recognise:(CDVInvokedUrlCommand *)command {
    callbackId = command.callbackId;
    RecognizeViewController *vc = [[RecognizeViewController alloc] init];
    vc.main = self;
    [self.viewController presentViewController:vc animated:YES completion:nil];
}

- (void) completeWith:(NSString *) result {
    CDVPluginResult * r = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:r callbackId:callbackId];
}

@end
