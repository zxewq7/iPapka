//
//  MeesterAppDelegate.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

@class MeesterViewController;

@interface MeesterAppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow *window;

    MeesterViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


@property (nonatomic, retain) IBOutlet MeesterViewController *viewController;

@end

