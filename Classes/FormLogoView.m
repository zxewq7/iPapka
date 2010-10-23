//
//  FormLogoView.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 23.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "FormLogoView.h"


@implementation FormLogoView


- (id)initWithFrame:(CGRect)frame 
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"DefaultFormLogo.png"]];

    CGRect f = imageView.frame;
    f.origin.x = frame.origin.x;
    f.origin.y = frame.origin.y;
    
    if ((self = [super initWithFrame:f])) 
    {
        [self addSubview:imageView];
    }
    
    [imageView release];
    return self;
}
@end
