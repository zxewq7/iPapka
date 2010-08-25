//
//  SegmentedTableCell.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SegmentedLabel;
@interface SegmentedTableCell : UITableViewCell 
{
	SegmentedLabel *segmentedLabel;
}

@property (nonatomic, retain, setter=setSegmentedLabel:) SegmentedLabel *segmentedLabel;
@end
