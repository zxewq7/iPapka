//
//  AttachmetsViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaintingToolsViewController.h"

@class AttachmentPageViewController, Attachment, PageControlWithMenu, DocumentManaged;
@interface AttachmentsViewController : UIViewController<UIGestureRecognizerDelegate, PaintingToolsDelegate>
{
    AttachmentPageViewController *currentPage;
    AttachmentPageViewController *nextPage;

    Attachment    *attachment;
    NSUInteger    attachmentIndex;
    CGFloat       originalHeight;
    CGFloat       originalWidth;
    BOOL          commenting;
    UITapGestureRecognizer *tapRecognizer;
    PageControlWithMenu *pageControl;
    DocumentManaged              *document;
}

@property (nonatomic, retain)           DocumentManaged              *document;
@property (nonatomic, assign)           NSUInteger                   attachmentIndex;
@property (nonatomic, retain, readonly) AttachmentPageViewController *currentPage;
@property (nonatomic, assign)           BOOL                         commenting;
@property (nonatomic, retain)           PageControlWithMenu          *pageControl;
-(void) rotate:(CGFloat) degreesAngle;
@end
