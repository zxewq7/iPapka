//
//  AttachmetsViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaintingToolsViewController.h"

@class AttachmentPageViewController, Attachment, PageControlWithMenu;
@interface AttachmentsViewController : UIViewController<UIGestureRecognizerDelegate, PaintingToolsDelegate>
{
    AttachmentPageViewController *currentPage;
    AttachmentPageViewController *nextPage;

    
    Attachment    *attachment;
    CGFloat       originalHeight;
    CGFloat       originalWidth;
    BOOL          commenting;
    UITapGestureRecognizer *tapRecognizer;
    PageControlWithMenu *pageControl;
}

@property (nonatomic, retain, setter=setAttachment:)   Attachment                   *attachment;
@property (nonatomic, retain, readonly)                AttachmentPageViewController *currentPage;
@property (nonatomic, assign, setter=setCommenting:)   BOOL                         commenting;
@property (nonatomic, retain, setter=setPageControl:)  PageControlWithMenu          *pageControl;
-(void) rotate:(CGFloat) degreesAngle;
@end
