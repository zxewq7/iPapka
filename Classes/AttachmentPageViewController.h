//
//  AttachmentPageViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 27.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintingView.h"

@class AttachmentPage, ImageScrollView, MBProgressHUD;
@interface AttachmentPageViewController : UIViewController<PaintingViewDelegate>
{
    AttachmentPage  *page;
    ImageScrollView *imageView;
}

@property (nonatomic, retain) AttachmentPage *page;
@property (nonatomic)         BOOL           pen;
@property (nonatomic)         BOOL           marker;
@property (nonatomic)         BOOL           eraser;
@property (nonatomic)         BOOL           stamper;
@property (nonatomic)         CGFloat        angle;
@property (nonatomic, retain) UIColor        *color;
@property (readonly)          CGSize         imageSize;
@property (nonatomic)         float          zoomScale;

- (void) setCommenting:(BOOL) state;
- (void) saveContent;

@end
