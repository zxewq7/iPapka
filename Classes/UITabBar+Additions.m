//
//  UITabBar+Additions.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 11.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "UITabBar+Additions.h"


@implementation UITabBar (FlatTabBar)
- (void)drawRect:(CGRect)rect {
    UIColor *color = self.backgroundColor;
    if (!color)
        color = [UIColor blackColor];
        
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextFillRect(context, rect);
}
@end
