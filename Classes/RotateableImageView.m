//
//  RotateableImageView.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 16.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "RotateableImageView.h"

@interface RotateableImageView(Private)
- (void) setBackground:(BOOL) force;
@end


@implementation RotateableImageView
@synthesize portraitImage, landscapeImage;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setBackground: YES];
        self.opaque = NO;    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    [self setBackground: NO];
}

- (void)dealloc {
    self.portraitImage = nil;
    self.landscapeImage = nil;
    [super dealloc];
}


@end

@implementation RotateableImageView(Private)
- (void) setBackground:(BOOL) force
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    BOOL currentOrientationPortrait = (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown);
    
    if (!force && (currentOrientationPortrait && prevOrientationPortrait))
        return;
    
    UIImage *image;
    
    if (currentOrientationPortrait)
        image = self.portraitImage;
    else
        image = self.landscapeImage;
    
    CGSize imageSize = image.size;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, imageSize.width, imageSize.height);
    self.image = image;
    
    prevOrientationPortrait = currentOrientationPortrait;
}
@end