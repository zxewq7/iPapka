//
//  DocumentCellView.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 23.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentCellView.h"
#import "AZZSegmentedLabel.h"

#define kLeftMargin 10.f
#define kRightMargin 5.f
#define kLabelsSpaceBetweenImageView 10.f
#define kSpaceBetweenLabels 1.f
#define kSpaceBetweenTextLabelAndAttachmentImageView 5.f

@implementation DocumentCellView
@synthesize textLabel, detailTextLabel1, detailTextLabel2, detailTextLabel3, attachmentImageView, imageView;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:imageView];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:textLabel];
        
        detailTextLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
        detailTextLabel1.backgroundColor = [UIColor clearColor];
        [self addSubview:detailTextLabel1];

        detailTextLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
        detailTextLabel2.backgroundColor = [UIColor clearColor];
        [self addSubview:detailTextLabel2];

        detailTextLabel3 = [[AZZSegmentedLabel alloc] initWithFrame:CGRectZero];
        detailTextLabel3.backgroundColor = [UIColor clearColor];
        [self addSubview:detailTextLabel3];

        attachmentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:attachmentImageView];

        
    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];

    CGSize size = self.bounds.size;
    
    CGSize imageViewSize = imageView.image.size;

    CGSize attachmentImageViewSize = attachmentImageView.image.size;
    
    [textLabel sizeToFit];
    
    [detailTextLabel1 sizeToFit];
    
    [detailTextLabel2 sizeToFit];
    
    CGFloat labelLeftMargin = kLeftMargin + imageViewSize.width + kLabelsSpaceBetweenImageView;
    
    CGFloat labelWidth = size.width - labelLeftMargin - kRightMargin;
    
    CGFloat labelsHeight = textLabel.bounds.size.height + detailTextLabel1.bounds.size.height + detailTextLabel2.bounds.size.height + detailTextLabel3.bounds.size.height + kSpaceBetweenLabels;
    
    //textLabel
    
    CGRect textLabelFrame = CGRectMake(labelLeftMargin, 
                                       round((size.height - labelsHeight) / 2), 
                                       labelWidth, 
                                       textLabel.bounds.size.height);
    textLabel.frame = textLabelFrame;
    
    //detailsTextLabel1
    CGRect detailTextLabel1Frame = CGRectMake(labelLeftMargin, 
                                       textLabelFrame.origin.y + textLabelFrame.size.height + kSpaceBetweenLabels, 
                                       (detailTextLabel1.bounds.size.width > labelWidth?labelWidth:detailTextLabel1.bounds.size.width),
                                       detailTextLabel1.bounds.size.height);

    detailTextLabel1.frame = detailTextLabel1Frame;

    //detailsTextLabel2
    CGRect detailTextLabel2Frame = CGRectMake(labelLeftMargin, 
                                             detailTextLabel1Frame.origin.y + detailTextLabel1Frame.size.height + kSpaceBetweenLabels, 
                                              (detailTextLabel2.bounds.size.width > labelWidth?labelWidth:detailTextLabel2.bounds.size.width),
                                              detailTextLabel2.bounds.size.height);
    
    detailTextLabel2.frame = detailTextLabel2Frame;

    //detailsTextLabel3
    CGRect detailTextLabel3Frame = CGRectMake(labelLeftMargin, 
                                              detailTextLabel2Frame.origin.y + detailTextLabel2Frame.size.height + kSpaceBetweenLabels, 
                                              detailTextLabel3.bounds.size.width,
                                              detailTextLabel3.bounds.size.height);
    
    detailTextLabel3.frame = detailTextLabel3Frame;

    
    //attachmentImageView
    CGRect attachmentImageViewFrame = CGRectMake(detailTextLabel3Frame.origin.x + detailTextLabel3Frame.size.width + kSpaceBetweenTextLabelAndAttachmentImageView, 
                                       detailTextLabel3Frame.origin.y + round((detailTextLabel3Frame.size.height - attachmentImageViewSize.height) / 2), 
                                       attachmentImageViewSize.width, 
                                       attachmentImageViewSize.height);
    attachmentImageView.frame = attachmentImageViewFrame;
    
    //imageView
    CGRect imageViewFrame = CGRectMake(kLeftMargin, 
                                       textLabelFrame.origin.y + round((textLabelFrame.size.height - imageViewSize.height) / 2), 
                                       imageViewSize.width, 
                                       imageViewSize.height);
    imageView.frame = imageViewFrame;
}

- (void)dealloc 
{
    [textLabel release]; textLabel = nil;
    
    [detailTextLabel1 release]; detailTextLabel1 = nil;
    
    [detailTextLabel2 release]; detailTextLabel2 = nil;
    
    [detailTextLabel3 release]; detailTextLabel3 = nil;
    
    [attachmentImageView release]; attachmentImageView = nil;
    
    [imageView release]; imageView = nil;
    
    [super dealloc];
}
@end
