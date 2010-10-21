//
//  BubbleView.m
//  Slider
//
//  Created by Vladimir Solomenchuk on 10.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "AZZCalloutView.h"

@implementation AZZCalloutView


- (id)initWithFrame:(CGRect)f {

    UIImage *leftCap = [UIImage imageNamed:@"CalloutViewLeftCap.png"];
    
    UIImage *centerAnchor = [UIImage imageNamed:@"CalloutViewBottomAnchor.png"];
    
    UIImage *rightCap = [UIImage imageNamed:@"CalloutViewRightCap.png"];
    
    CGFloat centerWidth = centerAnchor.size.width;
    capSize = leftCap.size;
    
    minWidth = centerWidth + 2 * capSize.width;

    CGRect frame = CGRectMake(f.origin.x, f.origin.y, [self optimalWidthForContent:f.size.width], capSize.height);

    if ((self = [super initWithFrame:frame])) 
    {
        UIImage *background = [UIImage imageNamed:@"CalloutViewBackground.png"];
        
        UIImage *backgroundStretched = [background stretchableImageWithLeftCapWidth:0.0f topCapHeight:0.0f];
        
        leftView = [[UIImageView alloc] initWithImage:leftCap];
        CGRect leftViewFrame = CGRectMake(0, 0, capSize.width, capSize.height);
        leftView.frame = leftViewFrame;

        centerView = [[UIImageView alloc] initWithImage:centerAnchor];
        CGRect centerViewFrame = centerView.frame;
        centerViewFrame.origin.x = round ((frame.size.width - centerWidth) / 2);
        centerViewFrame.origin.y = 0;
        centerView.frame = centerViewFrame;
        centerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        rightView = [[UIImageView alloc] initWithImage:rightCap];
        CGRect rightViewFrame = CGRectMake(frame.size.width - capSize.width, 0, capSize.width, capSize.height);
        rightView.frame = rightViewFrame;
        rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

        leftBackgroundView = [[UIImageView alloc] initWithImage:backgroundStretched];
        CGRect leftBackgroundViewFrame = CGRectMake(leftViewFrame.origin.x + leftViewFrame.size.width, 0, centerViewFrame.origin.x - leftViewFrame.origin.x - leftViewFrame.size.width, capSize.height);
        leftBackgroundView.frame = leftBackgroundViewFrame;

        
        rigthBackgroundView = [[UIImageView alloc] initWithImage:backgroundStretched];
        CGRect rigthBackgroundViewFrame = CGRectMake(centerViewFrame.origin.x + centerViewFrame.size.width, 0, rightViewFrame.origin.x - centerViewFrame.origin.x - centerViewFrame.size.width, capSize.height);
        rigthBackgroundView.frame = rigthBackgroundViewFrame;

        CGRect contentViewFrame = CGRectMake(capSize.width, 4, frame.size.width - 2 * capSize.width, 45 - 4*2);
        contentView = [[UIView alloc] initWithFrame:contentViewFrame];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [self addSubview:leftView];
        [self addSubview:leftBackgroundView];
        [self addSubview:centerView];
        [self addSubview:rightView];
        [self addSubview:rigthBackgroundView];
        [self addSubview:contentView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect leftViewFrame = leftView.frame;
    
    CGRect centerViewFrame = centerView.frame;
    
    CGRect leftBackgroundViewFrame = CGRectMake(leftViewFrame.origin.x + leftViewFrame.size.width, 0, centerViewFrame.origin.x - leftViewFrame.origin.x - leftViewFrame.size.width, leftViewFrame.size.height);
    leftBackgroundView.frame = leftBackgroundViewFrame;
    
    CGRect rightViewFrame = rightView.frame;
    
    CGRect rigthBackgroundViewFrame = CGRectMake(centerViewFrame.origin.x + centerViewFrame.size.width, 0, rightViewFrame.origin.x - centerViewFrame.origin.x - centerViewFrame.size.width, rightViewFrame.size.height);
    rigthBackgroundView.frame = rigthBackgroundViewFrame;
    
}

- (CGFloat) optimalWidthForContent:(CGFloat) width
{
    if (width < (minWidth - 2 * capSize.width))
        return minWidth;
    else
        return minWidth + 2 * round((width - minWidth) / 2) + 2 * capSize.width;
}

- (CGFloat) contentWidth
{
    return self.frame.size.width - 2 * capSize.width;
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
    return contentView;
}

- (void)animationDidStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    self.hidden = (self.alpha == 0.0);
}

- (void)dealloc 
{
    [leftView release];
    
    [centerView release];
    
    [rightView release];
    
    [leftBackgroundView release];
    
    [rigthBackgroundView release];
    
    [contentView release];

    [super dealloc];
}
@end
