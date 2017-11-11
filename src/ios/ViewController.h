
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureSession.h>
#import <AVFoundation/AVCaptureStillImageOutput.h>
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>
#import <AVFoundation/AVCaptureVideoDataOutput.h>
#import "DocCrop.h"

@interface ViewController : UIViewController<UIImagePickerControllerDelegate>
@property (readwrite) DocCrop *main1;
@end

