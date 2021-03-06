//
//  iPapkaAppDelegate.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {

    UIWindow                *window;

    RootViewController      *rootViewController;
    
    NSTimer                 *syncTimer;
}

@property (nonatomic, retain) IBOutlet UIWindow                 *window;

@property (nonatomic, retain) IBOutlet RootViewController       *rootViewController;
@end

