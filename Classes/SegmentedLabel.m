//
//  SegmentedLabel.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 18.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SegmentedLabel.h"


@implementation SegmentedLabel
@synthesize labels, texts;

-(void)setLabels:(NSArray *)theLabels
{
    if (labels == theLabels)
        return;
    NSArray *views = self.subviews;
    NSUInteger length = [views count];
    for (NSUInteger i=0;i<length;i++) 
        [[views objectAtIndex:i] removeFromSuperview];
    
    [labels release];
    labels = [theLabels retain];
    
    for (UILabel *label in labels) 
        [self addSubview:label];
}

-(void)setTexts:(NSArray *)theTexts
{
    if (texts == theTexts)
        return;
    
    [texts release];
    texts = [theTexts retain];
    
    NSUInteger length = [self.labels count];
    NSUInteger textsLength = [texts count];
    CGFloat maxHeight = 0;
    for (NSUInteger i=0;i<length;i++) 
    {
        UILabel *label = [self.labels objectAtIndex:i];
        if (i<textsLength)
            label.text = [texts objectAtIndex:i];
        else
            label.text = @"";
        
        [label sizeToFit];
        CGRect f = label.frame;
        maxHeight = MAX(maxHeight, f.size.height);
    }
    
    CGFloat x = 0;
    for (UILabel *label in labels) 
    {
        CGRect f = label.frame;
        f.origin.x = x;
        f.origin.y =  maxHeight-f.size.height;
        label.frame = f;
        x = f.origin.x+f.size.width;
    }
    
    CGRect viewFrame = self.frame;

    viewFrame.size.height = maxHeight;
    
    CGRect lastLabelFrame = ((UIView *)[labels lastObject]).frame;
    
    viewFrame.size.width = lastLabelFrame.origin.x + lastLabelFrame.size.width;
    
    self.frame = viewFrame;
}
-(void) dealloc
{
    self.texts = nil;
    self.labels = nil;
    [super dealloc];
}
@end