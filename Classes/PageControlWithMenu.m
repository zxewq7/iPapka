//
//  PageControlWithMenu.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PageControlWithMenu.h"

#define BACKGROUND_VIEW_TAG 1001

@interface PageControlWithMenu (Private)
- (void) updateDots;
@end

@implementation PageControlWithMenu
@synthesize bubbleView, backgroundView, dotNormal, dotCurrent;
@dynamic currentPageBypass;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        backgroundView = [[UIImageView alloc] initWithFrame: frame];
        backgroundView.tag = BACKGROUND_VIEW_TAG;
        [self addSubview: backgroundView];
    }
    return self;
}

-(void) showBubble
{
    bubbleView.hidden = NO;
}

- (void)setCurrentPageBypass:(NSInteger)aPage {
	[self setCurrentPage:aPage];
	[self setNeedsDisplay];
    [self showBubble];
}

- (NSInteger)currentPageBypass {
	return self.currentPage;
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
            if (dot.tag == BACKGROUND_VIEW_TAG)
                continue;
            // Set image
            dot.image = (i == self.currentPage) ? dotCurrent : dotNormal;
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, dotSize.width, dotSize.height);
            i++;
        }
    }
}
@end
