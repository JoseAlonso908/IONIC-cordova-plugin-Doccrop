
#import "ResultController.h"

@interface ResultController ()

@end

UIImageView *myImage;

@implementation ResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWid = screenRect.size.width;
    
    myImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, (screenHeight - screenWid/3*4)/2, screenWid, screenWid/3*4)];

    myImage.image = _resultimg;
    myImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:myImage];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(rotateClick:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Rotate" forState:UIControlStateNormal];
    button.frame = CGRectMake(screenWid/4-50, screenHeight - 40, 100, 30);
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 addTarget:self
                action:@selector(finishClick:)
      forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"Finish" forState:UIControlStateNormal];
    button1.frame = CGRectMake(screenWid/4*3-50, screenHeight - 40, 100, 30);
    [self.view addSubview:button1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)rotateClick:(id)sender{
    _resultimg = rotatedImage(_resultimg, M_PI/2);
    myImage.image = _resultimg;
}

-(IBAction)finishClick:(id)sender{

    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/YOUR_IMG_FOLDER"];
    
    if (![fileMgr fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    //Get the current date and time and set as image name
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *gmtTime = [dateFormatter stringFromDate:now];
    NSLog(@"The Current Time is :%@", gmtTime);
    
    NSData *imageData = UIImageJPEGRepresentation(_resultimg, 0.5); // _postImage is your image file and you can use JPEG representation or PNG as your wish
    int imgSize = imageData.length;
    ////NSLog(@"SIZE OF IMAGE: %.2f Kb", (float)imgSize/1024);
    
    NSString *imgfileName = [NSString stringWithFormat:@"%@%@", gmtTime, @".jpg"];
    // File we want to create in the documents directory
    NSString *imgfilePath= [dataPath stringByAppendingPathComponent:imgfileName];
    // Write the file
    [imageData writeToFile:imgfilePath atomically:YES];
    _resultimg = [CVWrapper brightimage:_resultimg];
    // UIImageWriteToSavedPhotosAlbum(_resultimg, nil, nil, nil);
    [self.main completeWith:imgfilePath];
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:NO completion:nil];
    
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskPortrait;
}

UIImage *rotatedImage(UIImage *image, CGFloat rotation) // rotation in radians
{
    // Calculate Destination Size
    CGAffineTransform t = CGAffineTransformMakeRotation(rotation);
    CGRect sizeRect = (CGRect) {.size = image.size};
    CGRect destRect = CGRectApplyAffineTransform(sizeRect, t);
    CGSize destinationSize = destRect.size;
    
    // Draw image
    UIGraphicsBeginImageContext(destinationSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, destinationSize.width / 2.0f, destinationSize.height / 2.0f);
    CGContextRotateCTM(context, rotation);
    [image drawInRect:CGRectMake(-image.size.width / 2.0f, -image.size.height / 2.0f, image.size.width, image.size.height)];
    
    // Save image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};


@end
