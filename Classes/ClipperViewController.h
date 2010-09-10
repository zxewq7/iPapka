//
//  ClipperViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ClipperViewController : UIViewController<UIGestureRecognizerDelegate> 
{
    UIImageView *clipperImageView;
    UITapGestureRecognizer *tapRecognizer;
    BOOL opened;
}
- (CGFloat) contentOffset;
@property (nonatomic, assign, setter = setOpened:) BOOL opened;
@end
