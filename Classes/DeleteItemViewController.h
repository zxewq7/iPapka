//
//  DeleteItemViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 04.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DeleteItemViewController : UIViewController 
{
    UIPopoverController *popoverController;
    void (^handler)();
    UIView *targetView;
}

+ (DeleteItemViewController *)sharedDeleteItemViewController;
- (void) showForView:(UIView *) aView handler:(void (^)(UIView *target))handler;
@end
