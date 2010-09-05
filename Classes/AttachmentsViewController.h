//
//  AttachmetsViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AttachmentPageViewController, Attachment;
@interface AttachmentsViewController : UIViewController<UIScrollViewDelegate> 
{
    UIScrollView *pagingScrollView;
    
    AttachmentPageViewController *currentPage;
    AttachmentPageViewController *nextPage;

    
    Attachment    *attachment;
    CGRect        viewFrame;
    CGFloat       originalHeight;
    CGFloat       originalWidth;
    BOOL          commenting;
}

@property (nonatomic, retain, setter=setAttachment:)   Attachment                   *attachment;
@property (nonatomic, retain, readonly)                AttachmentPageViewController *currentPage;
@property (nonatomic, assign, setter=setCommenting:)   BOOL                           commenting;
-(void) rotate:(CGFloat) degreesAngle;
@end
