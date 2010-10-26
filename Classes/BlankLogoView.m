//
//  FormLogoView.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 23.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "BlankLogoView.h"


@implementation BlankLogoView


- (id)initWithFrame:(CGRect)frame 
{
    UIImage *imageLogo = nil;
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *blankLogoPath = [currentDefaults valueForKey:@"blankLogoPath"];
    
    if (blankLogoPath)
        imageLogo = [UIImage imageWithContentsOfFile:blankLogoPath];
    
    if (!imageLogo)
        imageLogo = [UIImage imageNamed: @"BlankLogo.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:imageLogo];

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
