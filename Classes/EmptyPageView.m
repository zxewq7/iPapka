//
//  EmptyPageView.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 02.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "EmptyPageView.h"


@implementation EmptyPageView


- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PageLoading.png"]];
        imageView.center = CGPointMake((round(frame.size.width) / 2), round(frame.size.height / 2));

        imageView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        
        [self addSubview:imageView];
        
        [imageView release];
    }
    return self;
}
@end
