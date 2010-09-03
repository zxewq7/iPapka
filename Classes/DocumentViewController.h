//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged, AttachmentsViewController, DocumentInfoViewController, AttachmentPickerController;

@interface DocumentViewController : UIViewController<UIPopoverControllerDelegate>
{
    UINavigationController       *navigationController;
    DocumentManaged *document;
    AttachmentsViewController    *attachmentsViewController;
    DocumentInfoViewController *infoViewController;
    UIButton                   *infoButton;
    UIButton                   *penButton;
    UIButton                   *eraseButton;
    UIButton                   *commentButton;
    UIButton                   *attachmentButton;
    UIToolbar                  *leftToolbar;
    UIToolbar                  *rightToolbar;
    AttachmentPickerController *attachmentPickerController;
    UIPopoverController        *popoverController;
}

@property (nonatomic, retain) IBOutlet UINavigationController       *navigationController;

@property (nonatomic, retain, setter=setDocument:) DocumentManaged *document;

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;

- (void) showDocumentInfo:(id) sender;

-(void) showAttachmentsList:(id) sender;
@end
