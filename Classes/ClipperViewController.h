//
//  ClipperViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 10.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClipperViewController : UIViewController<UIGestureRecognizerDelegate> 
{
    BOOL opened;
}
- (CGFloat) contentOffset;
@property (nonatomic, assign, setter = setOpened:) BOOL opened;

//this method will configue tapzones for clipper and should be called after adding clipper to superview.
//it will create several tapzones over clipper (due to rectangular nature of image)
- (void) counfigureTapzones;
@end
