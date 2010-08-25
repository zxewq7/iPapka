//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged, AttachmentsViewController, DocumentInfoViewController;

@interface DocumentViewController : UIViewController
{
    UIToolbar       *toolbar;
    UIBarButtonItem *documentTitle;
    DocumentManaged *document;
    AttachmentsViewController    *attachmentsViewController;
    DocumentInfoViewController *infoViewController;
    UIButton                   *infoButton;
    UIButton                   *penButton;
    UIButton                   *eraseButton;
    UIButton                   *commentButton;
}

@property (nonatomic, retain) IBOutlet UIToolbar       *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *documentTitle;

@property (nonatomic, retain, setter=setDocument:) DocumentManaged *document;

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;

- (void) showDocumentInfo:(id) sender;
@end
