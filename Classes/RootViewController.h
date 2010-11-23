//
//  DocumentViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentsListViewController.h"

@class RootDocument, AttachmentsViewController, ClipperViewController, DocumentInfoViewController, PaintingToolsViewController, ResolutionViewController, RotateableImageView, SignatureCommentViewController, MBProgressHUD;

@interface RootViewController : UIViewController<DocumentsListDelegate>
{
    RootDocument                *document;
    AttachmentsViewController   *attachmentsViewController;
    UIToolbar                   *toolbar;
    ClipperViewController       *clipperViewController;
    DocumentInfoViewController  *documentInfoViewController;
    PaintingToolsViewController *paintingToolsViewController;
    CGFloat                     contentHeightOffset;
    RotateableImageView         *contentView;
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
    CGSize documentInfoViewControllerSize;
}

@property (nonatomic, retain, setter=setDocument:) RootDocument *document;
@end
