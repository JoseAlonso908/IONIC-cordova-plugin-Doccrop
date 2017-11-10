//
//  Rectangle.h
//  DocBox
//
//  Created by Dan Bucholtz on 4/19/14.
//  Copyright (c) 2014 Mod618. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rectangle : NSObject{
    CGFloat topLeftX;
    CGFloat topLeftY;
    CGFloat topRightX;
    CGFloat topRightY;
    CGFloat bottomLeftX;
    CGFloat bottomLeftY;
    CGFloat bottomRightX;
    CGFloat bottomRightY;
}

@property(nonatomic, assign) CGFloat topLeftX;
@property(nonatomic, assign) CGFloat topLeftY;
@property(nonatomic, assign) CGFloat topRightX;
@property(nonatomic, assign) CGFloat topRightY;
@property(nonatomic, assign) CGFloat bottomLeftX;
@property(nonatomic, assign) CGFloat bottomLeftY;
@property(nonatomic, assign) CGFloat bottomRightX;
@property(nonatomic, assign) CGFloat bottomRightY;

@end
