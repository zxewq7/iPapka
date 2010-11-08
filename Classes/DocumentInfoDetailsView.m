//
//  DocumentInfoDetailsView.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 26.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentInfoDetailsView.h"
#import "AZZSegmentedLabel.h"

#define kSpaceBetweenLabels 8.f

@implementation DocumentInfoDetailsView


@synthesize textLabel, detailTextLabel1, detailTextLabel2;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.textColor = [UIColor blackColor];
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.font = [UIFont fontWithName:@"CharterC" size:24];
        textLabel.backgroundColor = [UIColor clearColor];

        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        textLabel.frame = CGRectMake(0, 0, frame.size.width, 24);

        [self addSubview:textLabel];

        detailTextLabel1 = [[AZZSegmentedLabel alloc] initWithFrame:CGRectZero];

        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
        label1.textColor = [UIColor colorWithRed:0.804 green:0.024 blue:0.024 alpha:1.0];
        label1.highlightedTextColor = [UIColor whiteColor];
        label1.font = [UIFont boldSystemFontOfSize:12.f];
        label1.backgroundColor = [UIColor clearColor];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
        label2.textColor = [UIColor colorWithRed:0.718 green:0.635 blue:0.173 alpha:1.0];
        label2.highlightedTextColor = [UIColor whiteColor];
        label2.font = [UIFont boldSystemFontOfSize:12.f];
        label2.backgroundColor = [UIColor clearColor];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectZero];
        label3.textColor = [UIColor colorWithRed:0.118 green:0.506 blue:0.051 alpha:1.0];
        label3.highlightedTextColor = [UIColor whiteColor];
        label3.font = [UIFont boldSystemFontOfSize:12.f];
        label3.backgroundColor = [UIColor clearColor];
        
        detailTextLabel1.labels = [NSArray arrayWithObjects:label1, label2, label3, nil];

        
        [self addSubview:detailTextLabel1];

        detailTextLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
        detailTextLabel2.textColor = [UIColor darkGrayColor];
        detailTextLabel2.font = [UIFont fontWithName:@"CharterC" size:14];
        detailTextLabel2.backgroundColor = [UIColor clearColor];
        [self addSubview:detailTextLabel2];
    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    [detailTextLabel2 sizeToFit];
    
    //textLabel
    
    CGRect textLabelFrame = textLabel.frame;
    
    textLabel.frame = textLabelFrame;
    
    
    //detailsTextLabel1
    
    CGFloat detailLabelsWidth = MIN(size.width, detailTextLabel1.bounds.size.width + detailTextLabel2.bounds.size.width);
    
    CGRect detailTextLabel1Frame = CGRectMake(round((size.width - detailLabelsWidth)/2), 
                                              textLabelFrame.origin.y + textLabelFrame.size.height + kSpaceBetweenLabels, 
                                              detailTextLabel1.bounds.size.width,
                                              detailTextLabel1.bounds.size.height);
    
    detailTextLabel1.frame = detailTextLabel1Frame;
    
    //detailsTextLabel2
    CGRect detailTextLabel2Frame = CGRectMake(detailTextLabel1Frame.origin.x + detailTextLabel1Frame.size.width, 
                                              detailTextLabel1Frame.origin.y,
                                              detailLabelsWidth - detailTextLabel1Frame.size.width,
                                              detailTextLabel2.bounds.size.height);
    
    detailTextLabel2.frame = detailTextLabel2Frame;
}

- (void)dealloc 
{
    [textLabel release]; textLabel = nil;
    
    [detailTextLabel1 release]; detailTextLabel1 = nil;
    
    [detailTextLabel2 release]; detailTextLabel2 = nil;
    
    [super dealloc];
}

@end
