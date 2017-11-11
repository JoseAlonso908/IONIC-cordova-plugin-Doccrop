
#import <UIKit/UIKit.h>
#import "CVWrapper.h"
#import "DocCrop.h"

@interface ResultController : UIViewController

@property(nonatomic,retain) UIImage* resultimg;
@property (readwrite) DocCrop *main;

@end
