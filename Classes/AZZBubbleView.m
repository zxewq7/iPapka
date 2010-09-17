//
//  BubbleView.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "AZZBubbleView.h"
#import <QuartzCore/CALayer.h>


@implementation AZZBubbleView
@synthesize pointY, pointWidth, pointHeight, rectColor, arrowPosition, pointX;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.arrowPosition = AZZPositionLeft;
        self.pointX = frame.size.width/2;
        self.pointY = frame.size.height/2;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat radius = self.layer.cornerRadius;
    
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > self.bounds.size.width/2.0) radius = self.bounds.size.width/2.0;
    if (radius > self.bounds.size.height/2.0) radius = self.bounds.size.height/2.0;

    CGFloat minx;
    CGFloat midx;
    CGFloat maxx;
    CGFloat miny;
    CGFloat midy;
    CGFloat maxy;
    
    
    /*
     CGContextMoveToPoint(context, minx, midy);
     CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
     CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
     CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
     CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
     */
    
    switch (arrowPosition)
    {
        case AZZPositionLeft:
            minx = CGRectGetMinX(self.bounds) + pointWidth;
            midx = CGRectGetMidX(self.bounds);
            maxx = CGRectGetMaxX(self.bounds);
            miny = CGRectGetMinY(self.bounds);
            midy = CGRectGetMidY(self.bounds);
            maxy = CGRectGetMaxY(self.bounds);

            CGContextMoveToPoint(context, minx, miny + pointY);
            CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
            CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
            CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
            CGContextAddArcToPoint(context, minx, maxy, minx, miny + pointY + pointHeight, radius);
            CGContextAddLineToPoint (context, minx, miny + pointY + pointHeight);
            CGContextAddLineToPoint (context, minx - pointWidth, miny + pointY + (pointHeight / 2));
            break;
        case AZZPositionBottom:
            minx = CGRectGetMinX(self.bounds) + pointWidth;
            midx = CGRectGetMidX(self.bounds);
            maxx = CGRectGetMaxX(self.bounds);
            miny = CGRectGetMinY(self.bounds);
            midy = CGRectGetMidY(self.bounds);
            maxy = CGRectGetMaxY(self.bounds);
            
            CGContextMoveToPoint(context, minx, miny + pointY);
            CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
            CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
            CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
            CGContextAddArcToPoint(context, minx, maxy, minx, miny + pointY + pointHeight, radius);
            CGContextAddLineToPoint (context, minx, miny + pointY + pointHeight);
            CGContextAddLineToPoint (context, minx - pointWidth, miny + pointY + (pointHeight / 2));
            break;
    }
    
    CGContextClosePath(context);
    
    [rectColor setFill];
    CGContextDrawPath(context, kCGPathFill);
}

- (void)dealloc {
    self.rectColor = nil;
    [super dealloc];
}


@end
