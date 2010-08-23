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
#import "DataSource.h"

@implementation AppDelegate


@synthesize viewController, window, navigationController, rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        //Create dictionary
	NSMutableDictionary* defaultValues = [NSMutableDictionary dictionary];
    
        //default folders
    Folder *inbox = [Folder folderWith:@"Resolutions" predicateString:nil andEntityName:@"Resolution"];
    NSArray* defaultFolders = [NSArray arrayWithObjects:
                                    inbox,
                                    [Folder folderWith:@"Signatures" predicateString:nil andEntityName:@"Signature"],
                                    nil];
    [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:defaultFolders] forKey:@"folders"];
    [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:inbox] forKey:@"lastFolder"];

#warning test default settings
    
//    [defaultValues setObject:@"http://10.0.2.4/~vovasty" forKey:@"serverHost"];
//    [defaultValues setObject:@"C325777C0045161D.json" forKey:@"serverDatabase"];
//    [defaultValues setObject:@"89FB7FB8A9330311C325777C004EEFC8" forKey:@"serverDatabaseView"];
//    [defaultValues setObject:@"serverAuthLogin" forKey:@"serverAuthLogin"];
//    [defaultValues setObject:@"serverAuthPassword" forKey:@"serverAuthPassword"];

    [defaultValues setObject:@"http://195.208.68.133/cm35" forKey:@"serverHost"];
    [defaultValues setObject:@"prvz.nsf" forKey:@"serverDatabase"];
    [defaultValues setObject:@"4e99dcdd2e11c8a9c3257785003fa928" forKey:@"serverDatabaseView"];
    [defaultValues setObject:@"Vasya V pupken/turumbay" forKey:@"serverAuthLogin"];
    [defaultValues setObject:@"1" forKey:@"serverAuthPassword"];
    
    
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
    [[DataSource sharedDataSource] refreshDocuments];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {

    NSUInteger unreadCount = 0;
    NSArray *folders = nil;
    DataSource *ds = [DataSource sharedDataSource];
    
    NSData *foldersData = [[NSUserDefaults standardUserDefaults] objectForKey:@"folders"];
    if (foldersData != nil)
        folders = [NSKeyedUnarchiver unarchiveObjectWithData:foldersData];
    
    for (Folder *folder in folders) 
        unreadCount+=[ds countUnreadDocumentsForFolder:folder];

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
    [ds shutdown];
}

- (void)dealloc {

    self.window = nil;
    self.viewController = nil;
    self.navigationController = nil;
    self.rootViewController = nil;
    [super dealloc];
}

@end

