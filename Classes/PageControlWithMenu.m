//
//  PageControlWithMenu.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PageControlWithMenu.h"

#define BACKGROUNDVIEW_TAG 1001
#define LABEL_TAG 1002

@interface PageControlWithMenu (Private)
- (void) updateDots;
@end

@implementation PageControlWithMenu
@synthesize bubbleView, backgroundView, dotNormal, dotCurrent, label;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        backgroundView = [[UIImageView alloc] initWithFrame: frame];
        backgroundView.tag = BACKGROUNDVIEW_TAG;
        [self addSubview: backgroundView];
    }
    return self;
}

-(void) setLabel:(UILabel *) aLabel
{
    if (label == aLabel)
        return;
    
    label = [aLabel retain];
    
    CGRect frame = self.frame;
    label.text = @"999 of 999";
    [label sizeToFit];
    
    CGSize labelSize = label.frame.size;
    
    label.frame = CGRectMake(frame.size.width - labelSize.width, (frame.size.height - labelSize.height)/2, labelSize.width, labelSize.height);
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    label.tag = LABEL_TAG;
    
    label.text = nil;
    [self addSubview: label];
}

-(void) showBubble
{
    bubbleView.hidden = NO;
}

- (void)dealloc 
{
    [backgroundView release];
    [bubbleView release];
    self.dotCurrent = nil;
    self.dotNormal = nil;
    [super dealloc];
}

/** override to update dots */
- (void) setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    
    // update dot views
    [self updateDots];
}

/** override to update dots */
- (void) updateCurrentPageDisplay
{
    [super updateCurrentPageDisplay];
    
    // update dot views
    [self updateDots];
}

/** Override setImageNormal */
- (void) setDotNormal:(UIImage*)image
{
    if (dotNormal == image)
        return;
    
    [dotNormal release];
    dotNormal = [image retain];
    
    dotSize = dotNormal.size;
    // update dot views
    [self updateDots];
}

/** Override setImageCurrent */
- (void) setDotCurrent:(UIImage*)image
{
    if (dotCurrent == image)
        return;
    
    [dotCurrent release];
    dotCurrent = [image retain];
    
    // update dot views
    [self updateDots];
}

/** Override to fix when dots are directly clicked */
- (void) endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event 
{
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self updateDots];
}

#pragma mark - (Private)

- (void) updateDots
{
    if(dotCurrent || dotNormal)
    {
        // Get subviews
        NSArray* dotViews = self.subviews;
        NSUInteger i = 0;
        for (UIImageView* dot in dotViews)
        {
            if (dot.tag == BACKGROUNDVIEW_TAG || dot.tag == LABEL_TAG)
                continue;
            // Set image
            dot.image = (i == self.currentPage) ? dotCurrent : dotNormal;
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, dotSize.width, dotSize.height);
            i++;
        }
    }
    
    label.text = [NSString stringWithFormat: @"%d %@ %d", self.currentPage + 1, NSLocalizedString(@"of", "of"), self.numberOfPages];
}
@end
