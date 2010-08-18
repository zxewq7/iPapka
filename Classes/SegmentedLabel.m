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
        //    [theLabels release];

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
    CGFloat x = 0;
    for (NSUInteger i=0;i<length;i++) 
    {
        UILabel *label = [self.labels objectAtIndex:i];
        if (i<textsLength)
            label.text = [texts objectAtIndex:i];
        else
            label.text = @"";

        [label sizeToFit];
        CGRect f = label.frame;
        label.frame = CGRectMake(f.origin.x+x, f.origin.y, f.size.width, f.size.height);
        x = label.frame.origin.x+label.frame.size.width;
    }

}
-(void) dealloc
{
    self.texts = nil;
    self.labels = nil;
    [super dealloc];
}
@end
