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
@property (nonatomic, retain, readonly, getter=drawings) UIImage       *drawings;

- (void) updateViews:(BOOL)force;
- (void) setCommenting:(BOOL) state;
@end
