//
//  DocumentCellView.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 23.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentCellView.h"

#define kLeftMargin 5.f
#define kRightMargin 5.f
#define kLabelsSpaceBetweenImageView 5.f
#define kSpaceBetweenLabels 5.f
#define kSpaceBetweenTextLabelAndAttachmentImageView 5.f

@implementation DocumentCellView
@synthesize textLabel, detailTextLabel, attachmentImageView, imageView;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:imageView];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:textLabel];
        
        detailTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailTextLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:detailTextLabel];
        
        attachmentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:attachmentImageView];

        
    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];

    CGSize size = self.bounds.size;
    
    //imageView
    CGSize imageViewSize = imageView.image.size;
    CGRect imageViewFrame = CGRectMake(kLeftMargin, 
                                       round((size.height - imageViewSize.height) / 2), 
                                       imageViewSize.width, 
                                       imageViewSize.height);
    imageView.frame = imageViewFrame;

    CGSize attachmentImageViewSize = attachmentImageView.image.size;
    
    [textLabel sizeToFit];
    
    [detailTextLabel sizeToFit];
    
    CGFloat labelLeftMargin = imageViewFrame.origin.x + imageViewSize.width + kLabelsSpaceBetweenImageView;
    
    CGFloat labelWidth = size.width - labelLeftMargin - kRightMargin;
    
    CGFloat labelsHeight = textLabel.bounds.size.height + detailTextLabel.bounds.size.height + kSpaceBetweenLabels;
    
    //textLabel
    
    CGFloat textLabelMinusWidth = (attachmentImageViewSize.width >0 ?(attachmentImageViewSize.width + kSpaceBetweenTextLabelAndAttachmentImageView):0);
    
    CGRect textLabelFrame = CGRectMake(labelLeftMargin, 
                                       round((size.height - labelsHeight) / 2), 
                                       ((textLabel.bounds.size.width + textLabelMinusWidth) > labelWidth?(labelWidth - textLabelMinusWidth):textLabel.bounds.size.width), 
                                       textLabel.bounds.size.height);
    textLabel.frame = textLabelFrame;
    
    //detailsTextLabel
    CGRect detailTextLabelFrame = CGRectMake(labelLeftMargin, 
                                       textLabelFrame.origin.y + textLabelFrame.size.height + kSpaceBetweenLabels, 
                                       (detailTextLabel.bounds.size.width > labelWidth?labelWidth:detailTextLabel.bounds.size.width),
                                       detailTextLabel.bounds.size.height);

    detailTextLabel.frame = detailTextLabelFrame;
    
    //attachmentImageView
    CGRect attachmentImageViewFrame = CGRectMake(textLabelFrame.origin.x + textLabelFrame.size.width + kSpaceBetweenTextLabelAndAttachmentImageView, 
                                       textLabelFrame.origin.y + round((textLabelFrame.size.height - attachmentImageViewSize.height) / 2), 
                                       attachmentImageViewSize.width, 
                                       attachmentImageViewSize.height);
    attachmentImageView.frame = attachmentImageViewFrame;
}

- (void)dealloc 
{
    [textLabel release]; textLabel = nil;
    
    [detailTextLabel release]; detailTextLabel = nil;
    
    [attachmentImageView release]; attachmentImageView = nil;
    
    [imageView release]; imageView = nil;
    
    [super dealloc];
}
@end
