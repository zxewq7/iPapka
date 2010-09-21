//
//  AttachmentPageViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 27.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintingView.h"

@class Attachment, ImageScrollView;
@interface AttachmentPageViewController : UIViewController<PaintingViewDelegate>
{
	NSInteger       pageIndex;
	BOOL            viewNeedsUpdate;

    Attachment      *attachment;
    ImageScrollView *imageView;
    BOOL pen;
    BOOL marker;
    BOOL eraser;
    BOOL stamper;
    CGFloat angle;
    
}

@property (nonatomic)         NSInteger     pageIndex;
@property (nonatomic, retain) Attachment    *attachment;
@property (nonatomic)         BOOL pen;
@property (nonatomic)         BOOL marker;
@property (nonatomic)         BOOL eraser;
@property (nonatomic)         BOOL stamper;
@property (nonatomic)         CGFloat angle;
@property (nonatomic, retain) UIColor *color;
- (void) updateViews:(BOOL)force;
- (void) setCommenting:(BOOL) state;
- (void) saveContent;
@end
