//
//  MasterViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 19.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SegmentedLabel;
@interface MasterViewController : UITableViewController {
    UIActivityIndicatorView *activityIndicator;
    SegmentedLabel          *activityLabel;
    NSDateFormatter         *activityDateFormatter;
    NSDateFormatter         *activityTimeFormatter;
}

@property (nonatomic, retain) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic, retain) SegmentedLabel            *activityLabel;
@property (nonatomic, retain) NSDateFormatter           *activityDateFormatter;
@property (nonatomic, retain) NSDateFormatter           *activityTimeFormatter;
- (void)setActivity:(BOOL) isProgress message:(NSString *) aMessage, ...;
-(void)refreshDocuments:(id)sender;
@end
