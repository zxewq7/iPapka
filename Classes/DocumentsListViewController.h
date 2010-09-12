//
//  MainViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoldersViewController, Folder;

@class DocumentsListViewController, DocumentManaged;

@protocol DocumentsListDelegate <NSObject>

-(void) documentDidChanged:(DocumentsListViewController *) sender;

@end
    

@interface DocumentsListViewController : UITableViewController {
	
    NSMutableDictionary     *sections;
    NSMutableArray          *sectionsOrdered;
    NSMutableArray          *sectionsOrderedLabels;
    NSDateFormatter         *dateFormatter;
    NSArray                 *sortDescriptors;
    Folder                  *folder;
    UILabel                 *titleLabel;
    UILabel                 *detailsLabel;
    NSDateFormatter         *activityDateFormatter;
    NSDateFormatter         *activityTimeFormatter;
    id<DocumentsListDelegate> delegate;
    DocumentManaged         *document;
}
@property (nonatomic, retain) NSMutableDictionary       *sections;
@property (nonatomic, retain) NSMutableArray            *sectionsOrdered;
@property (nonatomic, retain) NSMutableArray            *sectionsOrderedLabels;
@property (nonatomic, retain) NSDateFormatter           *dateFormatter;
@property (nonatomic, retain) NSArray                   *sortDescriptors;
@property (nonatomic, retain, setter=setFolder:) Folder *folder;

@property (nonatomic, retain) NSDateFormatter           *activityDateFormatter;
@property (nonatomic, retain) NSDateFormatter           *activityTimeFormatter;
@property (nonatomic, retain) id<DocumentsListDelegate> delegate;
@property (nonatomic, retain) DocumentManaged           *document;
-(void)dismiss:(id)sender;
@end
