

#import <Cordova/CDVPlugin.h>

@interface DocCrop : CDVPlugin

- (void) cropresult:(CDVInvokedUrlCommand*)command;
- (void) completeWith:(NSString *) result;

@end
