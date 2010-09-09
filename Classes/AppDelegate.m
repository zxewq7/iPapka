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
#import "NSUserDefaults+Additions.h"

@implementation AppDelegate
@synthesize viewController, window, navigationController, rootViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    //Create dictionary
	NSMutableDictionary* defaultValues = [NSUserDefaults defaultsFromSettingsBundle];
    
    //default folders
    Folder *inbox = [Folder folderWith:@"Resolutions" predicateString:@"dataSourceId = \"inbox\"" andEntityName:@"Resolution"];
    NSArray* defaultFolders = [NSArray arrayWithObjects:
                               inbox,
                               [Folder folderWith:@"Signatures" predicateString:@"dataSourceId = \"inbox\"" andEntityName:@"Signature"],
                               [Folder folderWith:@"Archive" predicateString:@"dataSourceId = \"archive\"" andEntityName:@"Document"],
                               nil];
    [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:defaultFolders] forKey:@"folders"];
    [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:inbox] forKey:@"lastFolder"];
    
    [defaultValues setObject:@"ProcessedRest" forKey:@"serverDatabaseViewArchive"];
    [defaultValues setObject:@"documents" forKey:@"serverDatabaseViewInbox"];
    
    //Register the dictionary of defaults
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
	[currentDefaults registerDefaults:defaultValues];
    [currentDefaults synchronize];
    
    
    
    NSData *lastFolderData = [currentDefaults objectForKey:@"lastFolder"];
    Folder *lastFolder;
    if (lastFolderData != nil)
        lastFolder = [NSKeyedUnarchiver unarchiveObjectWithData:lastFolderData];
    
    self.rootViewController.folder = lastFolder;
    [self.navigationController pushViewController:self.rootViewController animated:NO];
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
#warning disbled refresh on startup
    //    [[DataSource sharedDataSource] refreshDocuments];
    
    //splash screen
    //http://michael.burford.net/2008/11/fading-defaultpng-when-iphone-app.html
    switch ([UIApplication sharedApplication].statusBarOrientation) 
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 1024, 768)];
            splashView.image = [UIImage imageNamed:@"Default-Landscape.png"];
            break;
        default:
            splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 768, 1024)];
            splashView.image = [UIImage imageNamed:@"Default.png"];
            break;
    }
    [window addSubview:splashView];
    [window bringSubviewToFront:splashView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];
    [UIView setAnimationDelegate:self]; 
    [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
    splashView.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [splashView removeFromSuperview];
    [splashView release];
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