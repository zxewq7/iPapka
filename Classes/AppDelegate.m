//
//  MeesterAppDelegate.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import "AppDelegate.h"
#import "RootViewController.h"
#import "Folder.h"

@implementation AppDelegate


@synthesize viewController, window, navigationController, rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        //Create dictionary
	NSMutableDictionary* defaultValues = [NSMutableDictionary dictionary];
    Folder *inbox = [Folder folderWith:@"Inbox" andPredicateString:@"SELF.isLoaded == YES"];
    NSArray* defaultFolders = [NSArray arrayWithObjects:
                                    inbox,
                                    [Folder folderWith:@"Archive" andPredicateString:@"SELF.isLoaded == NO"],
                                    nil];
    [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:defaultFolders] forKey:@"folders"];
    [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:inbox] forKey:@"lastFolder"];
        //Register the dictionary of defaults
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
	[currentDefaults registerDefaults:defaultValues];
    
    
    
    NSData *lastFolderData = [currentDefaults objectForKey:@"lastFolder"];
    Folder *lastFolder;
    if (lastFolderData != nil)
        lastFolder = [NSKeyedUnarchiver unarchiveObjectWithData:lastFolderData];

    self.rootViewController.folder = lastFolder;
    [self.navigationController pushViewController:self.rootViewController animated:NO];
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {

    // Save data if appropriate.
}

- (void)dealloc {

    self.window = nil;
    self.viewController = nil;
    self.navigationController = nil;
    self.rootViewController = nil;
    [super dealloc];
}

@end

