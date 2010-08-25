//
//  SegmentedTableCell.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SegmentedTableCell.h"
#import "SegmentedLabel.h"

@implementation SegmentedTableCell
@synthesize segmentedLabel;

-(void) setSegmentedLabel:(SegmentedLabel *)aLabel
{
    if (segmentedLabel==aLabel)
        return;
    [segmentedLabel removeFromSuperview];
    [segmentedLabel release];
    segmentedLabel = [aLabel retain];
    [self.contentView addSubview:segmentedLabel];
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
    CGSize labelSize = self.segmentedLabel.frame.size;
		
    CGRect labelFrame = CGRectMake(12, (self.contentView.frame.size.height-labelSize.height)/2, labelSize.width, labelSize.height);
    
    self.segmentedLabel.frame = labelFrame;	
}

- (void)dealloc {
	self.segmentedLabel = nil;	
    [super dealloc];
}
@end
