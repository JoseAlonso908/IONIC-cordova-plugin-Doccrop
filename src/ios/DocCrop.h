//
//  DocRecognize.h


#import <Cordova/CDVPlugin.h>
#import <TesseractOCR/TesseractOCR.h>

@interface DocRecognize : CDVPlugin

- (void) recognise:(CDVInvokedUrlCommand*)command;
- (void) completeWith:(NSString *) result;

@end
