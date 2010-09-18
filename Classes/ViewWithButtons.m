//
//  ViewWithButtons.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 18.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ViewWithButtons.h"

@implementation ViewWithButtons
@synthesize spaceBetweenButtons, spaceBetweenRows, contentVerticalAlignment;
@dynamic buttons;

-(void) setContentVerticalAlignment:(UIControlContentVerticalAlignment)aContentVerticalAlignment
{
    contentVerticalAlignment = aContentVerticalAlignment;
    [self setNeedsLayout];
}

-(void) setButtons:(NSArray *) newButtons
{
    [buttons release];
    
    if (newButtons)
        buttons = [newButtons retain];
    else
        buttons = nil;
    
    NSArray *svs = self.subviews;
    for (UIView * sv in svs)
        [sv removeFromSuperview];
    
    for (UIView *button in buttons)
        [self addSubview: button];
    
    [self setNeedsLayout];
}

-(NSArray *) buttons
{
    return buttons;
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) {
        spaceBetweenButtons = 0.0f;
        spaceBetweenRows = 0.0f;
    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];

    NSUInteger numButtons = [buttons count];
    
    if (!numButtons)
        return;

    CGSize boundsSize = self.bounds.size;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;

    CGRect *buttonFrames = malloc(numButtons * sizeof(struct CGRect));
    
    for (NSUInteger i = 0; i < numButtons; i++)
    {
        UIView *button = [buttons objectAtIndex: i];
        CGRect buttonFrame = button.frame;
        
        if ((x + buttonFrame.size.width) > boundsSize.width)
        {
            x = 0.0f;
            y += buttonFrame.size.height + spaceBetweenRows;
        }

        buttonFrame.origin.x = x;
        buttonFrame.origin.y = y;
        buttonFrames[i] = buttonFrame;

        x += buttonFrame.size.width + spaceBetweenButtons;
    }
    
    if (contentVerticalAlignment == UIControlContentVerticalAlignmentCenter)
    {
        CGFloat prevY = 0.0f;
        NSUInteger rowStart = 0;
        for (NSUInteger i = 0; i < numButtons; i++)
        {
            CGRect buttonFrame = buttonFrames[i];
            
            if (prevY != buttonFrame.origin.y) //fix x in row - align to center prev row
            {
                CGRect lastInRowButton = buttonFrames[i-1];
                CGFloat width = lastInRowButton.origin.x + lastInRowButton.size.width;

                CGFloat delta = (boundsSize.width - width) / 2;
                if (delta > 0.0f)
                {
                    for (NSUInteger ii = rowStart; ii < i; ii++)
                        buttonFrames[ii].origin.x += delta;
                }
                prevY = buttonFrame.origin.y;
                rowStart = i;
            }
        }
        //last row

        CGRect lastInRowButton = buttonFrames[numButtons-1];
        CGFloat width = lastInRowButton.origin.x + lastInRowButton.size.width;
        CGFloat delta = (boundsSize.width - width) / 2;
        if (delta > 0.0f) //fix x in row
        {
            for (NSUInteger ii = rowStart; ii < numButtons; ii++)
                buttonFrames[ii].origin.x += delta;
        }
    }
    
    for (NSUInteger i = 0; i < numButtons; i++)
    {
        UIView *button = [buttons objectAtIndex: i];
        button.frame = buttonFrames[i];
    }
    
    free(buttonFrames);
}

- (void)dealloc {
    [super dealloc];
    self.buttons = nil;
}
@end
