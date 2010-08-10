//
//  MeesterAppDelegate.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

@class SwitchViewController;

@interface MeesterAppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow *window;

    SwitchViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


@property (nonatomic, retain) IBOutlet SwitchViewController *viewController;

@end

