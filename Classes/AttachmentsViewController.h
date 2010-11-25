//
//  AttachmetsViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaintingToolsViewController.h"
#import "PageControl.h"

@class AttachmentPageViewController, Attachment, PaintingToolsViewController;
@interface AttachmentsViewController : UIViewController<UIGestureRecognizerDelegate, PaintingToolsDelegate, PageControlDelegate>
{
    AttachmentPageViewController *currentPage;
    AttachmentPageViewController *nextPage;

    Attachment                   *attachment;
    BOOL                         commenting;
    PageControl                  *pageControl;
    PaintingToolsViewController  *paintingTools;
    CGSize                       imageSize;
    float                        zoomScale;
}

@property (nonatomic, retain)           Attachment            *attachment;
@property (nonatomic, assign)           BOOL                         commenting;
@property (nonatomic, retain)           PageControl          *pageControl;
@property (nonatomic, retain)           PaintingToolsViewController  *paintingTools;
@end
