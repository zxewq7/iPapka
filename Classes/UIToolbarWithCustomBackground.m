//
//  UIToolbarWithCustomBackground.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "UIToolbarWithCustomBackground.h"


@implementation UIToolbarWithCustomBackground
- (void)drawRect:(CGRect)rect {
    UIColor *color = self.backgroundColor;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextFillRect(context, rect);
}
@end
