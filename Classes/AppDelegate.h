//
//  MeesterAppDelegate.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow                *window;

    UIViewController        *viewController;
    
    UINavigationController  *navigationController;
    
    RootViewController      *rootViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow                 *window;

@property (nonatomic, retain) IBOutlet UIViewController         *viewController;

@property (nonatomic, retain) IBOutlet UINavigationController   *navigationController;

@property (nonatomic, retain) IBOutlet RootViewController       *rootViewController;
@end

