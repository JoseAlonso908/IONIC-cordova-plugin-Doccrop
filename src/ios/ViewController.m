
#import "ViewController.h"
#import "CVWrapper.h"
#import "Rectangle.h"
#import "RectangleCALayer.h"
#import "PhotoCropViewController.h"
#import "RegionSelect.h"

@interface ViewController ()

@end

AVCaptureSession *session;
CALayer *rootLayer;
CAShapeLayer *line;
AVCaptureVideoPreviewLayer *previewLayer;
UIImage* resultimg;
UIButton *btnFlash;

CGFloat leftTX;
CGFloat leftTY;
CGFloat leftBX;
CGFloat leftBY;
CGFloat rightTX;
CGFloat rightTY;
CGFloat rightBX;
CGFloat rightBY;

//UIImageView* imageview;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    
    if ([inputDevice lockForConfiguration:&error])
    {
        // Exposure: Continuous
        if ([inputDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            inputDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        // White Balance: Continuous
        if ([inputDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
        {
            inputDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        }
        
        [inputDevice unlockForConfiguration];
    }
    else
    {
        NSLog(@"Cannot lock cam device, %@", [error localizedDescription]);
    }
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = CGRectMake(0, 0, rootLayer.bounds.size.width, rootLayer.bounds.size.height);

    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWid = screenRect.size.width;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(captureClick:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Capture" forState:UIControlStateNormal];
    button.frame = CGRectMake(screenWid/3*2-40, screenHeight - 40, 80, 30);
    [self.view addSubview:button];
    
    btnFlash = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFlash addTarget:self
               action:@selector(flashClick:)
     forControlEvents:UIControlEventTouchUpInside];
    [btnFlash setTitle:@"Flash" forState:UIControlStateNormal];
    btnFlash.frame = CGRectMake(screenWid/3-50, screenHeight - 40, 100, 30);
    [self.view addSubview:btnFlash];
    
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        [session startRunning];
    });
}

-(IBAction)captureClick:(id)sender{

    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            if ([flashLight isTorchActive])
            {
                [flashLight setTorchMode:AVCaptureTorchModeOff];
            }
//            else
//            {
//                [btnFlash setTitle:@"TURN OFF" forState:UIControlStateNormal];
//                [flashLight setTorchMode:AVCaptureTorchModeOn];
//            }
            [flashLight unlockForConfiguration];
        }
    }
    

    if(leftTX != 0 && leftTY != 0){
        PhotoCropViewController *controler = [[PhotoCropViewController alloc] initWithNibName:nil bundle:nil];
        controler.img = resultimg;
        controler.x1 = leftTX;
        controler.y1 = leftTY;
        controler.x2 = rightTX;
        controler.y2 = rightTY;
        controler.x3 = rightBX;
        controler.y3 = rightBY;
        controler.x4 = leftBX;
        controler.y4 = leftBY;
        [self presentViewController:controler animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Detection Fail!"
                                                        message:@"Try again"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(IBAction)flashClick:(id)sender{
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            if ([flashLight isTorchActive])
            {
                [flashLight setTorchMode:AVCaptureTorchModeOff];
            }
            else
            {
                [flashLight setTorchMode:AVCaptureTorchModeOn];
            }
            [flashLight unlockForConfiguration];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    resultimg = [self imageFromSampleBuffer:sampleBuffer];

    Rectangle *cornerPoints = [CVWrapper detectedSquaresInImage:resultimg];
    
    CGFloat imgwid = resultimg.size.width;
    CGFloat imghei = resultimg.size.height;
    CGFloat layerwid = rootLayer.bounds.size.width;
    CGFloat layerhei = layerwid/9*16;
    
    CGFloat scalewid = layerwid/imgwid;
    CGFloat scalehei = layerhei/imghei;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat offset = (screenHeight - layerhei)/2;
    
    leftTX = cornerPoints.topLeftX*scalewid;
    leftTY = cornerPoints.topLeftY*scalehei;
    rightTX = cornerPoints.topRightX*scalewid;
    rightTY = cornerPoints.topRightY*scalehei;
    rightBX = cornerPoints.bottomRightX*scalewid;
    rightBY = cornerPoints.bottomRightY*scalehei;
    leftBX = cornerPoints.bottomLeftX*scalewid;
    leftBY = cornerPoints.bottomLeftY*scalehei;
    
    CGPoint first = CGPointMake(leftTX, leftTY + offset);
    CGPoint second = CGPointMake(rightTX, rightTY + offset);
    CGPoint third = CGPointMake(rightBX, rightBY + offset);
    CGPoint fourth = CGPointMake(leftBX, leftBY + offset);
    
    [line removeFromSuperlayer];
    dispatch_async(dispatch_get_main_queue(), ^{

        [self makeLineLayer:rootLayer lineFromPointA:first toPointB:second toPointC:third toPointD:fourth];
    });
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];

    // Release the Quartz image
    CGImageRelease(quartzImage);

    return (image);
}

-(void)makeLineLayer:(CALayer *)layer lineFromPointA:(CGPoint)pointA toPointB:(CGPoint)pointB toPointC:(CGPoint)pointC toPointD:(CGPoint)pointD
{
    line = [CAShapeLayer layer];
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: pointA];
    [linePath addLineToPoint:pointB];
    [linePath moveToPoint: pointB];
    [linePath addLineToPoint:pointC];
    [linePath moveToPoint: pointC];
    [linePath addLineToPoint:pointD];
    [linePath moveToPoint: pointD];
    [linePath addLineToPoint:pointA];
    line.path=linePath.CGPath;
    line.fillColor = nil;
    line.lineWidth = 2.0;
    line.opacity = 1.0;
    line.strokeColor = [UIColor greenColor].CGColor;
    [[self.view layer] insertSublayer:line atIndex:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
