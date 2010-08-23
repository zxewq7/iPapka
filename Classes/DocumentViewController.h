//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged;

@interface DocumentViewController : UIViewController
{
    UIToolbar       *toolbar;
    UIBarButtonItem *documentTitle;
    DocumentManaged *document;
    UITableView     *tableView;
}

@property (nonatomic, retain) IBOutlet UIToolbar       *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *documentTitle;
@property (nonatomic, retain) IBOutlet UITableView     *tableView;

@property (nonatomic, retain, setter=setDocument:) DocumentManaged  *document;

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end
