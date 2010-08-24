//
//  AttachmetsViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageScrollView, Attachment;
@interface AttachmentsViewController : UIViewController<UIScrollViewDelegate> 
{
    UIScrollView *pagingScrollView;
    
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
    
        // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int           firstVisiblePageIndexBeforeRotation;
    CGFloat       percentScrolledIntoFirstVisiblePage;
    Attachment    *attachment;
    CGRect        viewFrame;
}

@property (nonatomic, retain, setter=setAttachment:)   Attachment    *attachment;
@end
