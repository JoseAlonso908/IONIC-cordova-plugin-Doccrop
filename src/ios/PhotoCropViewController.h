
#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "RegionSelect.h"
#import "ResultController.h"

@interface PhotoCropViewController : UIViewController

    @property (readwrite) DocCrop *main;
    @property(nonatomic,retain) UIImage* img;
    @property CGFloat x1;
    @property CGFloat y1;
    @property CGFloat x2;
    @property CGFloat y2;
    @property CGFloat x3;
    @property CGFloat y3;
    @property CGFloat x4;
    @property CGFloat y4;

    @property CGFloat rx1;



@end
