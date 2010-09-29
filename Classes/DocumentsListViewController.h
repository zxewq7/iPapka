//
//  MainViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/NSFetchedResultsController.h>

@class FoldersViewController, Folder;

@class DocumentsListViewController, DocumentManaged;

@protocol DocumentsListDelegate <NSObject>

-(void) documentDidChanged:(DocumentsListViewController *) sender;

@end
    

@interface DocumentsListViewController : UITableViewController<UITabBarDelegate, NSFetchedResultsControllerDelegate>
{
	
    NSDateFormatter         *dateFormatter;
    Folder                  *folder;
    NSUInteger              filterIndex;
    UILabel                 *titleLabel;
    UILabel                 *detailsLabel;
    NSDateFormatter         *activityDateFormatter;
    NSDateFormatter         *activityTimeFormatter;
    id<DocumentsListDelegate> delegate;
    DocumentManaged         *document;
    NSIndexPath             *selectedDocumentIndexPath;
    UITabBar                *filtersBar;
    NSFetchedResultsController *fetchedResultsController;
}
@property (nonatomic, retain) NSDateFormatter           *dateFormatter;
@property (nonatomic, retain, setter=setFolder:) Folder *folder;

@property (nonatomic, retain) NSDateFormatter           *activityDateFormatter;
@property (nonatomic, retain) NSDateFormatter           *activityTimeFormatter;
@property (nonatomic, retain) id<DocumentsListDelegate> delegate;
@property (nonatomic, retain) DocumentManaged           *document;
-(void)dismiss:(id)sender;
@end
