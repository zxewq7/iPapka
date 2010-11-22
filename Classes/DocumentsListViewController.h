//
//  MainViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 14.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/NSFetchedResultsController.h>

@class FoldersViewController, Folder;

@class DocumentsListViewController, DocumentWithResources;

@protocol DocumentsListDelegate <NSObject>

-(void) documentDidChanged:(DocumentsListViewController *) sender;

@end
    

@interface DocumentsListViewController : UITableViewController<UITabBarDelegate, NSFetchedResultsControllerDelegate>
{
	
    NSDateFormatter         *dateFormatter;
    NSDateFormatter         *timeFormatter;
    Folder                  *folder;
    NSUInteger              filterIndex;
    UILabel                 *titleLabel;
    UILabel                 *detailsLabel;
    NSDateFormatter         *activityDateFormatter;
    NSDateFormatter         *activityTimeFormatter;
    id<DocumentsListDelegate> delegate;
    DocumentWithResources   *document;
    UITabBar                *filtersBar;
    NSFetchedResultsController *fetchedResultsController;
    NSString                *sortField;
}
@property (nonatomic, retain, setter=setFolder:) Folder *folder;

@property (nonatomic, retain) id<DocumentsListDelegate> delegate;
@property (nonatomic, retain) DocumentWithResources     *document;
-(void)dismiss:(id)sender;
@end
