//
//  BubbleView.m
//  Slider
//
//  Created by Vladimir Solomenchuk on 10.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "AZZCalloutView.h"

#define kAZZContentView 1001

@implementation AZZCalloutView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
    {
        self.frame = frame;

        UIImage *background = [UIImage imageNamed:@"CalloutViewBackground.png"];
        
        UIImage *backgroundStretched = [background stretchableImageWithLeftCapWidth:0.0f topCapHeight:0.0f];
        
        UIImage *leftCap = [UIImage imageNamed:@"CalloutViewLeftCap.png"];

        UIImage *centerAnchor = [UIImage imageNamed:@"CalloutViewBottomAnchor.png"];

        UIImage *rightCap = [UIImage imageNamed:@"CalloutViewRightCap.png"];
        
        CGFloat centerWidth = centerAnchor.size.width;
        CGSize capSize = leftCap.size;
        
        UIImageView *leftView = [[UIImageView alloc] initWithImage:leftCap];
        CGRect leftViewFrame = CGRectMake(0, 0, capSize.width, capSize.height);
        leftView.frame = leftViewFrame;
        leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;

        UIImageView *centerView = [[UIImageView alloc] initWithImage:centerAnchor];
        CGRect centerViewFrame = centerView.frame;
        centerViewFrame.origin.x = (frame.size.width - centerWidth)/2;
        centerView.frame = centerViewFrame;
        centerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        UIImageView *rightView = [[UIImageView alloc] initWithImage:rightCap];
        CGRect rightViewFrame = CGRectMake(frame.size.width - capSize.width, 0, capSize.width, capSize.height);
        rightView.frame = rightViewFrame;
        rightView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        UIImageView *leftBackgroundView = [[UIImageView alloc] initWithImage:backgroundStretched];
        CGRect leftBackgroundViewFrame = CGRectMake(leftViewFrame.origin.x + leftViewFrame.size.width, 0, centerViewFrame.origin.x - leftViewFrame.origin.x - leftViewFrame.size.width, capSize.height);
        leftBackgroundView.frame = leftBackgroundViewFrame;
        leftBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        
        UIImageView *rigthBackgroundView = [[UIImageView alloc] initWithImage:backgroundStretched];
        CGRect rigthBackgroundViewFrame = CGRectMake(centerViewFrame.origin.x + centerViewFrame.size.width, 0, rightViewFrame.origin.x - centerViewFrame.origin.x - centerViewFrame.size.width, capSize.height);
        rigthBackgroundView.frame = rigthBackgroundViewFrame;
        rigthBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        CGRect contentViewFrame = CGRectMake(10, 4, frame.size.width - 2*10, 45 - 4*2);
        UIView *contentView = [[UIView alloc] initWithFrame:contentViewFrame];
        contentView.tag = kAZZContentView;

        [self addSubview:leftView];
        [self addSubview:leftBackgroundView];
        [self addSubview:centerView];
        [self addSubview:rightView];
        [self addSubview:rigthBackgroundView];
        [self addSubview:contentView];
        
        [leftView release];
        [centerView release];
        [rightView release];
        [leftBackgroundView release];
        [rigthBackgroundView release];
        [contentView release];
    }
    return self;
}

-(void) show
{
    if (!self.hidden)
        return;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStopped:finished:context:)];
    
    self.alpha = 1.0;
    
    [UIView commitAnimations];
}

-(void) hide
{
    if (self.hidden)
        return;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStopped:finished:context:)];
    
    self.alpha = 0.0;
    
    [UIView commitAnimations];
}

-(UIView*) contentView
{
    return [self viewWithTag:kAZZContentView];
}

- (void)animationDidStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    self.hidden = (self.alpha == 0.0);
}

@end