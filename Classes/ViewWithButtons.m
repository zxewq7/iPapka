//
//  ViewWithButtons.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 18.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ViewWithButtons.h"

@implementation ViewWithButtons
@synthesize spaceBetweenButtons, spaceBetweenRows, contentHorizontalAlignment;

-(void) setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)aContentHorizontalAlignment
{
    contentHorizontalAlignment = aContentHorizontalAlignment;
    [self setNeedsLayout];
}

-(void) setSubviews:(NSArray*) subviews;
{
    
    NSArray *svs = self.subviews;
    for (UIView * sv in svs)
        [sv removeFromSuperview];
    
    for (UIView *view in subviews)
        [self addSubview: view];
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
        self.autoresizesSubviews = NO;
    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    NSArray *subviews = self.subviews;
    NSUInteger numButtons = [subviews count];
    
    if (!numButtons)
        return;

    CGSize boundsSize = self.bounds.size;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;

    CGRect *buttonFrames = malloc(numButtons * sizeof(struct CGRect));
    
    for (NSUInteger i = 0; i < numButtons; i++)
    {
        UIView *button = [subviews objectAtIndex: i];
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
    
    if (contentHorizontalAlignment == UIControlContentHorizontalAlignmentCenter)
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

                CGFloat delta = round((boundsSize.width - width) / 2);
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
        CGFloat delta = round((boundsSize.width - width) / 2);
        if (delta > 0.0f) //fix x in row
        {
            for (NSUInteger ii = rowStart; ii < numButtons; ii++)
                buttonFrames[ii].origin.x += delta;
        }
    }
    
    for (NSUInteger i = 0; i < numButtons; i++)
    {
        UIView *button = [subviews objectAtIndex: i];
        CGRect buttonFrame = buttonFrames[i];
        button.frame = buttonFrame;
    }
    
    free(buttonFrames);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [self layoutSubviews];
    UIView *lastButton = [self.subviews lastObject];
    CGRect lastButtonFrame = lastButton.frame;
    return CGSizeMake(self.frame.size.width, lastButtonFrame.origin.y + lastButtonFrame.size.height);
}
@end
