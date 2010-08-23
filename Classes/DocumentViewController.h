//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Document;

@interface DocumentViewController : UIViewController
{
    UIToolbar       *toolbar;
    UIBarButtonItem *documentTitle;
    Document        *document;
    UITableView     *tableView;
}

@property (nonatomic, retain) IBOutlet UIToolbar       *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *documentTitle;
@property (nonatomic, retain) IBOutlet UITableView     *tableView;

@property (nonatomic, retain, setter=setDocument:) Document  *document;

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end
