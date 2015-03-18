//
//  LogView.m
//  Bananas
//
//  Created by marstall on 12/31/14.
//  Copyright (c) 2014 Two Pines. All rights reserved.
//

#import "LogView.h"
#import "Bananas.h"
@import UIKit;

@implementation LogView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        DDLogVerbose(@"logview init");
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

/*
    UIBezierPath *bp = [UIBezierPath bezierPath];
    int lineWidth = 1;
    bp.lineWidth = lineWidth;
    bp.lineCapStyle = kCGLineCapRound;
    int width = rect.size.width;
    int numSteps = width/lineWidth;
    float j=0.0;
    for (int i=0;i<width;i+=lineWidth)
    {
        j+=1.0;
        // convert 10 32 320 to 0.03 ....
        // convert 20 32 320 to 0.06 ...
        // ((a*b)/10)/c
        CGFloat redColor = ((float)lineWidth/(float)width)*j;
        UIColor * fillColor = [UIColor colorWithRed:redColor green:0.5 blue:0.5 alpha:0.1];
        [fillColor set];
        bp = [UIBezierPath bezierPath];
        bp.lineWidth = 10;
        bp.lineCapStyle = kCGLineCapRound;

        [bp moveToPoint:CGPointMake(i,0)];
        [bp addLineToPoint:CGPointMake(i,rect.size.height)];
        [bp stroke];
    }
    [bp stroke];
//    DDLogVerbose(self.text);
*/
    [self.mutableAttributedString drawInRect:rect];

}
@end
