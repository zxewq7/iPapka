//
//  EmptyPageView.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 02.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "EmptyPageView.h"


@implementation EmptyPageView


- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
//        imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PageLoading.png"]];
//        imageView.center = CGPointMake((round(frame.size.width) / 2), round(frame.size.height / 2));
//
//        imageView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
//        
//        [self addSubview:imageView];
//        
//        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        titleLabel.backgroundColor = [UIColor clearColor];
//        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
//        titleLabel.textAlignment = UITextAlignmentCenter;
//        titleLabel.textColor = [UIColor colorWithRed:0.216 green:0.243 blue:0.267 alpha:1.0];
//
//        titleLabel.text = NSLocalizedString(@"Page is not loaded", "Page is not loaded");
//        
//        [titleLabel sizeToFit];
//        [self addSubview:titleLabel];
//        
//        detailsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        detailsLabel.backgroundColor = [UIColor clearColor];
//        detailsLabel.font = [UIFont systemFontOfSize:14.0];
//        detailsLabel.textAlignment = UITextAlignmentCenter;
//        detailsLabel.textColor = [UIColor darkGrayColor];
//        
//        detailsLabel.text = NSLocalizedString(@"Try to look again later", "Try to look again later");
//        
//        [detailsLabel sizeToFit];
//        [self addSubview:detailsLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    titleLabel.center = CGPointMake((round(self.bounds.size.width) / 2), round(self.bounds.size.height / 2 + imageView.bounds.size.height / 1.5));
    detailsLabel.center = CGPointMake((round(self.bounds.size.width) / 2), round(self.bounds.size.height / 2 + imageView.bounds.size.height / 1.5) + titleLabel.bounds.size.height);
}

- (void)dealloc 
{
    [imageView release];
    
    [titleLabel release];
    
    [detailsLabel release];
    
    [super dealloc];
}
@end
