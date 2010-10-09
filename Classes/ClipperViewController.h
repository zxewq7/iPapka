//
//  ClipperViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ClipperViewController : UIViewController<UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate> 
{
    BOOL opened;
}
- (CGFloat) contentOffset;
@property (nonatomic, assign, setter = setOpened:) BOOL opened;

//this method will configue tapzones for clipper and should be called after adding clipper to superview.
//it will create several tapzones over clipper (due to rectangular nature of image)
- (void) counfigureTapzones;
- (void) silentClose;
@end
