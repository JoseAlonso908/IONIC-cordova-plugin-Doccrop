//
//  DocRecognize.m

#import "DocCrop.h"
#import "ResultController.h"
#import "ViewController.h"

@interface DocCrop ()
{
    NSString *callbackId;
}
@end

@implementation DocCrop

- (void) cropresult:(CDVInvokedUrlCommand *)command {
    callbackId = command.callbackId;
    ViewController* vc = [[ViewController alloc] init];
    vc.main1 = self;
    
    [self.viewController presentViewController:vc animated:YES completion:nil];
}

- (void) completeWith:(NSString *) result {
    CDVPluginResult * r = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:r callbackId:callbackId];
}

@end
