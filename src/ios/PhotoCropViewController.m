
#import "PhotoCropViewController.h"
#import "CVWrapper.h"

@interface PhotoCropViewController ()

@end

CGFloat screenHeight;
CGFloat screenWid;

@implementation PhotoCropViewController{
    RegionSelect* rs;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenHeight = screenRect.size.height;
    screenWid = screenRect.size.width;
    
    rs = [[RegionSelect alloc] initWithFrame:CGRectMake(0, (screenHeight - screenWid/9*16)/2, screenWid, screenWid/9*16)];
    
    rs.ltx = _x1;
    rs.lty = _y1;
    rs.rtx = _x2;
    rs.rty = _y2;
    rs.rbx = _x3;
    rs.rby = _y3;
    rs.lbx = _x4;
    rs.lby = _y4;
    
    NSLog(@"%@", [NSString stringWithFormat:@"%f",_x1]);

    UIGraphicsBeginImageContextWithOptions(rs.bounds.size, NO, 0.0);
    [_img drawInRect:rs.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    rs.backgroundColor = [UIColor colorWithPatternImage:image];
    [[self view] addSubview:rs];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(newPhotoClick:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"New Photo" forState:UIControlStateNormal];
    button.frame = CGRectMake(screenWid/4-50, screenHeight - 40, 100, 30);
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 addTarget:self
               action:@selector(cropClick:)
     forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"Crop" forState:UIControlStateNormal];
    button1.frame = CGRectMake(screenWid/4*3-50, screenHeight - 40, 100, 30);
    [self.view addSubview:button1];
}

-(IBAction)newPhotoClick:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
    ViewController *controler = [[ViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:controler animated:YES completion:NULL];
}

-(IBAction)cropClick:(id)sender{
    ResultController *controler = [[ResultController alloc] initWithNibName:nil bundle:nil];
    controler.main = self.main;
    
    CGPoint firstPt = [self makePoints:rs.lbx fy:rs.lby];
    CGPoint secondPt = [self makePoints:rs.rbx fy:rs.rby];
    CGPoint thirdPt = [self makePoints:rs.rtx fy:rs.rty];
    CGPoint fourthPt = [self makePoints:rs.ltx fy:rs.lty];
    NSLog(@"%@", [NSString stringWithFormat:@"%f",rs.lbx]);
    controler.resultimg = [CVWrapper cropImage:_img firstPt:firstPt secondPt:secondPt thirdPt:thirdPt fourthPt:fourthPt];
    [self presentViewController:controler animated:YES completion:nil];
//    [self dismissViewControllerAnimated:NO completion:nil];
}

- (CGPoint) makePoints:(CGFloat) rx1 fy:(CGFloat) ry1
{
    
    CGFloat layerwid = screenWid;
    CGFloat layerhei = screenWid/9*16;
    
    CGFloat imgwid = _img.size.width;
    CGFloat imghei = _img.size.height;
    
    CGFloat scalewid = layerwid/imgwid;
    CGFloat scalehei = layerhei/imghei;
    
    return (CGPointMake(rx1/scalewid, (ry1)/scalehei));
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
