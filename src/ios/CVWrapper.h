//
//  CVWrapper.h
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 Washe / Foundry. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>
#import "Rectangle.h"
#import "RectangleCALayer.h"

@interface CVWrapper : NSObject

+ (Rectangle*) detectedSquaresInImage:(UIImage*) image;
+ (UIImage*) cropImage:(UIImage*) image
              firstPt:(CGPoint) lbPt
              secondPt:(CGPoint) rbPt
              thirdPt:(CGPoint) rtPt
              fourthPt:(CGPoint) ltPt;
+ (UIImage*) brightimage:(UIImage*) image;

@end
