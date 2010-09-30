//
//  AttachmetsViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaintingToolsViewController.h"

@class AttachmentPageViewController, AttachmentManaged, PageControlWithMenu, PaintingToolsViewController;
@interface AttachmentsViewController : UIViewController<UIGestureRecognizerDelegate, PaintingToolsDelegate>
{
    AttachmentPageViewController *currentPage;
    AttachmentPageViewController *nextPage;

    AttachmentManaged           *attachment;
    BOOL                        commenting;
    UITapGestureRecognizer      *tapRecognizer;
    PageControlWithMenu         *pageControl;
    PaintingToolsViewController *paintingTools;
    NSUInteger                  currentPageIndex;
}

@property (nonatomic, retain)           AttachmentManaged            *attachment;
@property (nonatomic, assign)           BOOL                         commenting;
@property (nonatomic, retain)           PageControlWithMenu          *pageControl;
@property (nonatomic, retain)           PaintingToolsViewController  *paintingTools;
@end
