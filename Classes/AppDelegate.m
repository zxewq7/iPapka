//
//  iPapkaAppDelegate.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import "AppDelegate.h"
#import "RootViewController.h"
#import "Folder.h"
#import "DataSource.h"
#import "NSUserDefaults+Additions.h"
#import "Logger.h"

@implementation AppDelegate
@synthesize window, rootViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [Logger sharedLogger].redirectEnabled = YES;
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
    //Create dictionary
    NSMutableDictionary* defaultValues = [NSUserDefaults defaultsFromSettingsBundle];
    
    //default folders
    //names should be unique across all folders
    Folder *inbox = [Folder folderWithName:@"Documents" 
                           predicateString:nil
                                entityName:nil
                                  iconName:@"ButtonDocuments.png"];
    inbox.filters = [NSArray arrayWithObjects: 
                     [Folder folderWithName:@"Resolutions" 
                            predicateString:@"(status == 0 || status == 1)" 
                                 entityName:@"DocumentResolution"
                                   iconName:@"ButtonResolution.png"], 
                     [Folder folderWithName:@"Signatures" 
                            predicateString:@"(status == 0 || status == 1)" 
                                 entityName:@"DocumentSignature"
                                   iconName:@"ButtonSignature.png"],
                     nil];
    
    Folder *archive = [Folder folderWithName:@"Archive" 
                             predicateString:nil
                                  entityName:nil
                                    iconName:@"ButtonArchive.png"];
    
    archive.filters = [NSArray arrayWithObjects: 
                       [Folder folderWithName:@"Archived resolutions" 
                              predicateString:@"!(status == 0 || status == 1)" 
                                   entityName:@"DocumentResolution"
                                     iconName:@"ButtonResolution.png"], 
                       [Folder folderWithName:@"Archived signatures" 
                              predicateString:@"!(status == 0 || status == 1)" 
                                   entityName:@"DocumentSignature"
                                     iconName:@"ButtonSignature.png"],
                       nil];
    
    NSArray* defaultFolders = [NSArray arrayWithObjects:
                               inbox,
                               archive,
                               nil];
    [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:defaultFolders] forKey:@"folders"];
    
    [defaultValues setObject:@"ProcessedRest" forKey:@"serverDatabaseViewArchive"];
    [defaultValues setObject:@"documents" forKey:@"serverDatabaseViewInbox"];
    
    //Register the dictionary of defaults
    
    
    [currentDefaults registerDefaults:defaultValues];
    [currentDefaults synchronize];

    NSString *currentBundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *currentBundleShortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *currentVersion = [NSString stringWithFormat:@"%@(%@)", currentBundleShortVersion, currentBundleVersion];
    
    if (![[currentDefaults objectForKey:@"version"] isEqualToString:currentVersion])
    {
        [NSUserDefaults resetStandardUserDefaults];
        [currentDefaults setObject:currentVersion forKey:@"version"];
    }
    
    [self.window addSubview:rootViewController.view];
    [self.window makeKeyAndVisible];
    
    NSInteger interval = [currentDefaults integerForKey:@"serverSynchronizationInterval"];
    
    if (interval)
    {
        syncTimer = [NSTimer scheduledTimerWithTimeInterval:(interval * 60.0)
                                                     target:self 
                                                   selector:@selector(sync) 
                                                   userInfo:nil
                                                    repeats:YES];
        [[DataSource sharedDataSource] sync:YES];
    }
}

-(void) sync
{
    [[DataSource sharedDataSource] sync:NO];
}

- (void)applicationWillTerminate:(UIApplication *)application {

    [syncTimer invalidate]; syncTimer = nil;
    
    DataSource *ds = [DataSource sharedDataSource];

    NSUInteger unreadCount = [ds countUnreadDocuments];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];

    [ds shutdown];
    
    [[Logger sharedLogger] removeLogFile];
}

- (void)dealloc 
{

    self.window = nil;
    self.rootViewController = nil;
    [syncTimer invalidate]; [syncTimer release]; syncTimer = nil;
    [super dealloc];
}
@end