//
//  MainViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentedLabel;

@interface RootViewController : UITableViewController <UISplitViewControllerDelegate> {
	
	UISplitViewController *splitViewController;
    
    UIPopoverController     *popoverController;    
    UIBarButtonItem         *rootPopoverButtonItem;
    NSMutableDictionary     *sections;
    NSMutableArray          *sectionsOrdered;
    NSMutableArray          *sectionsOrderedLabels;
    NSDateFormatter         *dateFormatter;
    NSArray                 *sortDescriptors;
    UIActivityIndicatorView *activityIndicator;
    SegmentedLabel          *activityLabel;
}

@property (nonatomic, assign) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIBarButtonItem *rootPopoverButtonItem;

@property (nonatomic, retain) NSMutableDictionary     *sections;
@property (nonatomic, retain) NSMutableArray          *sectionsOrdered;
@property (nonatomic, retain) NSMutableArray          *sectionsOrderedLabels;
@property (nonatomic, retain) NSDateFormatter         *dateFormatter;
@property (nonatomic, retain) NSArray                 *sortDescriptors;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) SegmentedLabel          *activityLabel;
-(void)refreshDocuments:(id)sender;
-(void)showFolders:(id)sender;
@end
