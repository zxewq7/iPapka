//
//  DocumentViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentsListViewController.h"

@class Document, AttachmentsViewController, ClipperViewController, Folder, DocumentInfoViewController, PaintingToolsViewController, ResolutionViewController, RootContentView, SignatureCommentViewController, MBProgressHUD;

@interface RootViewController : UIViewController<DocumentsListDelegate>
{
    Document             *document;
    AttachmentsViewController   *attachmentsViewController;
    UIToolbar                   *toolbar;
    ClipperViewController       *clipperViewController;
    Folder                      *folder;
    DocumentInfoViewController  *documentInfoViewController;
    PaintingToolsViewController *paintingToolsViewController;
    CGFloat                     contentHeightOffset;
    RootContentView             *contentView;
    BOOL                        canEdit;
    UIButton                    *declineButton;
    UIButton                    *acceptButton;
    UIButton                    *infoButton;
    UIButton                    *resolutionButton;
    UIButton                    *backButton;
    UIButton                    *signatureCommentButton;
    ResolutionViewController    *resolutionViewController;
    SignatureCommentViewController *signatureCommentViewController;
    MBProgressHUD               *blockView;
}

@property (nonatomic, retain, setter=setDocument:) Document *document;
@property (nonatomic, retain, setter=setFolder:)   Folder          *folder;
@end
