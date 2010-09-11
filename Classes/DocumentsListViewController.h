//
//  MainViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoldersViewController, Folder;

@interface DocumentsListViewController : UITableViewController {
	
    NSMutableDictionary     *sections;
    NSMutableArray          *sectionsOrdered;
    NSMutableArray          *sectionsOrderedLabels;
    NSDateFormatter         *dateFormatter;
    NSArray                 *sortDescriptors;
    Folder                  *folder;
}
@property (nonatomic, retain) NSMutableDictionary       *sections;
@property (nonatomic, retain) NSMutableArray            *sectionsOrdered;
@property (nonatomic, retain) NSMutableArray            *sectionsOrderedLabels;
@property (nonatomic, retain) NSDateFormatter           *dateFormatter;
@property (nonatomic, retain) NSArray                   *sortDescriptors;
@property (nonatomic, retain, setter=setFolder:) Folder *folder;
@end
