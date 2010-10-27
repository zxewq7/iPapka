//
//  DocumentInfoDetailsView.m
//  Meester
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
        textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:textLabel];

        detailTextLabel1 = [[AZZSegmentedLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:detailTextLabel1];

        detailTextLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
        detailTextLabel2.backgroundColor = [UIColor clearColor];
        [self addSubview:detailTextLabel2];
    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    [textLabel sizeToFit];
    
    [detailTextLabel1 sizeToFit];
    
    //textLabel
    
    CGFloat textLabelWidth = MIN(size.width , textLabel.bounds.size.width);
    
    CGRect textLabelFrame = CGRectMake(round((size.width - textLabelWidth)/2),
                                       0.f, 
                                       textLabelWidth, 
                                       textLabel.bounds.size.height);
    textLabel.frame = textLabelFrame;
    
    
    //detailsTextLabel1
    
    CGFloat detailLabelsWidth = MAX(size.width, detailTextLabel1.bounds.size.width + detailTextLabel2.bounds.size.width);
    
    CGRect detailTextLabel1Frame = CGRectMake(round((size.width - detailLabelsWidth)/2), 
                                              textLabelFrame.origin.y + textLabelFrame.size.height + kSpaceBetweenLabels, 
                                              detailTextLabel1.bounds.size.width,
                                              detailTextLabel1.bounds.size.height);
    
    detailTextLabel1.frame = detailTextLabel1Frame;
    
    //detailsTextLabel2
    CGRect detailTextLabel2Frame = CGRectMake(detailTextLabel1Frame.origin.x + detailTextLabel1Frame.size.width, 
                                              detailTextLabel1Frame.origin.y,
                                              size.width - detailTextLabel1Frame.origin.x + detailTextLabel1Frame.size.width,
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
