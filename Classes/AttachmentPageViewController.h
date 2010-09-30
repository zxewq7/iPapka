//
//  AttachmentPageViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 27.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintingView.h"

@class PageManaged, ImageScrollView;
@interface AttachmentPageViewController : UIViewController<PaintingViewDelegate>
{
    PageManaged       *page;
    ImageScrollView   *imageView;
}

@property (nonatomic, retain) PageManaged       *page;
@property (nonatomic)         BOOL              pen;
@property (nonatomic)         BOOL              marker;
@property (nonatomic)         BOOL              eraser;
@property (nonatomic)         BOOL              stamper;
@property (nonatomic)         CGFloat           angle;
@property (nonatomic, retain) UIColor           *color;

- (void) setCommenting:(BOOL) state;
- (void) saveContent;
@end
