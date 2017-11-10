//
//  RegionSelect.m
//  DocCrop
//
//  Created by kangZhe on 11/8/17.
//  Copyright © 2017 Informatica. All rights reserved.
//

#import "RegionSelect.h"
#import "Rectangle.h"

@implementation RegionSelect

int currentTouch = -1;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    if (CGRectContainsPoint(_firstarea, touchLocation)) {
        currentTouch = 0;
    }else if (CGRectContainsPoint(_secondarea, touchLocation)){
        currentTouch = 1;
    }else if (CGRectContainsPoint(_thirdarea, touchLocation)){
        currentTouch = 2;
    }else if(CGRectContainsPoint(_fourtharea, touchLocation)){
        currentTouch = 3;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    switch (currentTouch) {
        case 0:
            _ltx = touchLocation.x;
            _lty = touchLocation.y;
            break;
        case 1:
            _rtx = touchLocation.x;
            _rty = touchLocation.y;
            break;
        case 2:
            _rbx = touchLocation.x;
            _rby = touchLocation.y;
            break;
        case 3:
            _lbx = touchLocation.x;
            _lby = touchLocation.y;
            break;
            
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    switch (currentTouch) {
        case 0:
            _ltx = touchLocation.x;
            _lty = touchLocation.y;
            currentTouch = -1;
            break;
        case 1:
            _rtx = touchLocation.x;
            _rty = touchLocation.y;
            currentTouch = -1;
            break;
        case 2:
            _rbx = touchLocation.x;
            _rby = touchLocation.y;
            currentTouch = -1;
            break;
        case 3:
            _lbx = touchLocation.x;
            _lby = touchLocation.y;
            currentTouch = -1;
            break;
            
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor colorWithRed:89.0f/255.0f
                                                     green:169.0f/255.0f
                                                      blue:255.0f/255.0f
                                                     alpha:1.0f].CGColor);
    CGContextMoveToPoint(context, _ltx, _lty);
    CGContextAddLineToPoint(context, _rtx, _rty);
    CGContextAddLineToPoint(context, _rbx, _rby);
    CGContextAddLineToPoint(context, _lbx, _lby);
    CGContextAddLineToPoint(context, _ltx, _lty);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:229.0f/255.0f
                                                            green:248.0f/255.0f
                                                             blue:255.0f/255.0f
                                                            alpha:0.7f].CGColor);
    CGFloat lineWidth = 2;
    
    _firstarea = CGRectMake(_ltx - 15, _lty - 15, 30.0, 30.0);
    CGRect borderRect1 = CGRectInset(_firstarea, lineWidth * 0.5, lineWidth * 0.5);
    CGContextFillEllipseInRect (context, borderRect1);
    CGContextStrokeEllipseInRect(context, borderRect1);
    
    _secondarea = CGRectMake(_rtx - 15, _rty - 15, 30.0, 30.0);
    CGRect borderRect2 = CGRectInset(_secondarea, lineWidth * 0.5, lineWidth * 0.5);
    CGContextFillEllipseInRect (context, borderRect2);
    CGContextStrokeEllipseInRect(context, borderRect2);
    
    _thirdarea = CGRectMake(_rbx - 15, _rby - 15, 30.0, 30.0);
    CGRect borderRect3 = CGRectInset(_thirdarea, lineWidth * 0.5, lineWidth * 0.5);
    CGContextFillEllipseInRect (context, borderRect3);
    CGContextStrokeEllipseInRect(context, borderRect3);
    
    _fourtharea = CGRectMake(_lbx - 15, _lby - 15, 30.0, 30.0);
    CGRect borderRect4 = CGRectInset(_fourtharea, lineWidth * 0.5, lineWidth * 0.5);
    CGContextFillEllipseInRect (context, borderRect4);
    CGContextStrokeEllipseInRect(context, borderRect4);
    
    
    CGContextFillPath(context);
    
}

@end
