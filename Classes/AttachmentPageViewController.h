//
//  AttachmentPageViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 27.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Attachment, ImageScrollView;
@interface AttachmentPageViewController : UIViewController 
{
	NSInteger       pageIndex;
	BOOL            viewNeedsUpdate;

    Attachment      *attachment;
    ImageScrollView *imageView;
}

@property (nonatomic, setter=setPageIndex:)              NSInteger     pageIndex;
@property (nonatomic, retain)                            Attachment    *attachment;

- (void) updateViews:(BOOL)force;
- (void) setCommenting:(BOOL) state;
- (void) saveContent;
- (void) rotate:(CGFloat) degressAngle;
- (void) enableMarker:(BOOL) enabled;
- (void) enableEraser:(BOOL) enabled;
- (void) enableStamper:(BOOL) enabled;
@end
