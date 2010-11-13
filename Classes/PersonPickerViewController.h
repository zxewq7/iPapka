//
//  PersonPickerViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 18.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/NSFetchedResultsController.h>

@class Person;
@interface PersonPickerViewController : UIViewController<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *persons;
    NSFetchedResultsController *fetchedResultsController;
    SEL action;
    id target;
    UITableView *tableView;
    UISegmentedControl *filterSwitcher;
    
    UIImage *iconChecked;
    UIImage *iconUnchecked;
}

@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) id target;
@property (nonatomic, retain) NSMutableArray *persons;
@end
