//
//  CVWrapper.mm
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

#import "CVWrapper.h"
#import "CVSquares.h"
#import "UIImage+OpenCV.h"

    //remove 'magic numbers' from original C++ source so we can manipulate them from obj-C


@implementation CVWrapper

+ (Rectangle*) detectedSquaresInImage:(UIImage*) image{
    
    std::vector<std::vector<cv::Point> >squares;
    std::vector<cv::Point> largest_square;
    
    cv::Mat mat = [image CVMat];
    
    find_squares(mat, squares);
    find_largest_square(squares, largest_square);
    Rectangle * rectangle;
    
    if (largest_square.size() == 4 ){
        NSMutableArray * points = [[NSMutableArray alloc] initWithCapacity:4];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(largest_square[0].x, largest_square[0].y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(largest_square[1].x, largest_square[1].y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(largest_square[2].x, largest_square[2].y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(largest_square[3].x, largest_square[3].y)]];
        
        // okay, sort it by the X, then split it
        NSArray * sortedArray = [points sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            CGPoint firstPoint = [obj1 CGPointValue];
            CGPoint secondPoint = [obj2 CGPointValue];
            if (firstPoint.x > secondPoint.x) {
                return NSOrderedDescending;
            } else if (firstPoint.x < secondPoint.x) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        // we're sorted on X, so grab two of those bitches and figure out top and bottom
        NSMutableArray * left = [[NSMutableArray alloc] initWithCapacity:2];
        NSMutableArray * right = [[NSMutableArray alloc] initWithCapacity:2];
        [left addObject:sortedArray[0]];
        [left addObject:sortedArray[1]];
        
        [right addObject:sortedArray[2]];
        [right addObject:sortedArray[3]];
        
        // okay, now sort each of those arrays on the Y access
        NSArray * sortedLeft = [left sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            CGPoint firstPoint = [obj1 CGPointValue];
            CGPoint secondPoint = [obj2 CGPointValue];
            if (firstPoint.y > secondPoint.y) {
                return NSOrderedDescending;
            } else if (firstPoint.y < secondPoint.y) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        NSArray * sortedRight = [right sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            CGPoint firstPoint = [obj1 CGPointValue];
            CGPoint secondPoint = [obj2 CGPointValue];
            if (firstPoint.y > secondPoint.y) {
                return NSOrderedDescending;
            } else if (firstPoint.y < secondPoint.y) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        CGPoint topLeftOriginal = [[sortedLeft objectAtIndex:0] CGPointValue];
        
        CGPoint topRightOriginal = [[sortedRight objectAtIndex:0] CGPointValue];
        
        CGPoint bottomLeftOriginal = [[sortedLeft objectAtIndex:1] CGPointValue];
        
        CGPoint bottomRightOriginal = [[sortedRight objectAtIndex:1] CGPointValue];
        
        rectangle = [[Rectangle alloc] init];
        
        
        rectangle.bottomLeftX = bottomLeftOriginal.x;
        rectangle.bottomRightX = bottomRightOriginal.x;
        rectangle.topLeftX = topLeftOriginal.x;
        rectangle.topRightX = topRightOriginal.x;
        
        rectangle.bottomLeftY = bottomLeftOriginal.y;
        rectangle.bottomRightY = bottomRightOriginal.y;
        rectangle.topLeftY = topLeftOriginal.y;
        rectangle.topRightY = topRightOriginal.y;
    }
    
    return rectangle;
}

double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

void find_squares(cv::Mat& image, std::vector<std::vector<cv::Point> >&squares) {
    
    // blur will enhance edge detection
    cv::Mat blurred(image);
    medianBlur(image, blurred, 7);
    
    cv::Mat gray0(blurred.size(), CV_8U), gray;
    std::vector<std::vector<cv::Point> > contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++)
        {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0){
                Canny(gray0, gray, 20, 100, 3); //
                
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else{
                gray = gray0 >= (l+1) * 255 / threshold_level;
                //cv::Size size = image.size();
                //cv::adaptiveThreshold(gray0, gray, threshold_level, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, (size.width + size.height) / 200, l);
            }
            
            // Find contours and store them in a list
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            std::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                //if (approx.size() == 4 && fabs(contourArea(cv::Mat(approx))) > 100 && isContourConvex(cv::Mat(approx)))
                if (approx.size() == 4 && fabs(contourArea(cv::Mat(approx))) > 500 ){
                    //if ( approx.size() == 4 ){
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++){
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3)
                        squares.push_back(approx);
                }
            }
        }
    }
}

void find_largest_square(const std::vector<std::vector<cv::Point> >& squares, std::vector<cv::Point>& biggest_square)
{
    if (!squares.size()){
        // no squares detected
        return;
    }
    
    double maxArea = 0;
    int largestIndex = -1;
    
    for ( int i = 0; i < squares.size(); i++){
        std::vector<cv::Point> square = squares[i];
        double area = contourArea(cv::Mat(square));
        if ( area >= maxArea){
            largestIndex = i;
            maxArea = area;
        }
    }
    if ( largestIndex >= 0 && largestIndex < squares.size() ){
        biggest_square = squares[largestIndex];
    }
    return;
}

+ (UIImage*) cropImage:(UIImage*) image
               firstPt:(CGPoint) lbPt
               secondPt:(CGPoint) rbPt
               thirdPt:(CGPoint) rtPt
               fourthPt:(CGPoint) ltPt
{
//    cv::Mat originalRot ;
    cv::Mat original = [image CVMat];
//    cv::transpose(originalRot, original);
    
//    originalRot.release();
    
//    cv::flip(original, original, 1);
    
    
//    CGFloat scaleFactor =  [_sourceImageView contentScale];
    
    CGPoint ptBottomLeft = lbPt;
    CGPoint ptBottomRight = rbPt;
    CGPoint ptTopRight = rtPt;
    CGPoint ptTopLeft = ltPt;
    
    CGFloat w1 = sqrt( pow(ptBottomRight.x - ptBottomLeft.x , 2) + pow(ptBottomRight.x - ptBottomLeft.x, 2));
    CGFloat w2 = sqrt( pow(ptTopRight.x - ptTopLeft.x , 2) + pow(ptTopRight.x - ptTopLeft.x, 2));
    
    CGFloat h1 = sqrt( pow(ptTopRight.y - ptBottomRight.y , 2) + pow(ptTopRight.y - ptBottomRight.y, 2));
    CGFloat h2 = sqrt( pow(ptTopLeft.y - ptBottomLeft.y , 2) + pow(ptTopLeft.y - ptBottomLeft.y, 2));
    
    CGFloat maxWidth = (w1 < w2) ? w1 : w2;
    CGFloat maxHeight = (h1 < h2) ? h1 : h2;
    
    cv::Point2f src[4], dst[4];
    src[0].x = ptTopLeft.x;
    src[0].y = ptTopLeft.y;
    src[1].x = ptTopRight.x;
    src[1].y = ptTopRight.y;
    src[2].x = ptBottomRight.x;
    src[2].y = ptBottomRight.y;
    src[3].x = ptBottomLeft.x;
    src[3].y = ptBottomLeft.y;
    
    dst[0].x = 0;
    dst[0].y = 0;
    dst[1].x = maxWidth - 1;
    dst[1].y = 0;
    dst[2].x = maxWidth - 1;
    dst[2].y = maxHeight - 1;
    dst[3].x = 0;
    dst[3].y = maxHeight - 1;
    
    cv::Mat undistorted = cv::Mat( cvSize(maxWidth,maxHeight), CV_8UC4);
    cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
    
    UIImage *newImage = [UIImage imageWithCVMat:undistorted];
    
    undistorted.release();
    original.release();
    
//    [_sourceImageView setNeedsDisplay];
//    [_sourceImageView setImage:newImage];
//    [_sourceImageView setContentMode:UIViewContentModeScaleAspectFit];
    return newImage;
    
}

+ (UIImage*) brightimage:(UIImage*) image{
    cv::Mat original = [image CVMat];
    original.convertTo(original, -1,1.2);
    UIImage *newImage = [UIImage imageWithCVMat:original];
    original.release();
    return newImage;
    
}



@end
