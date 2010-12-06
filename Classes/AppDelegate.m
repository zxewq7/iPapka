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

@interface AppDelegate (Private)
-(void) purgeData;
@end


@implementation AppDelegate
@synthesize window, rootViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
    //Create dictionary
    NSMutableDictionary* defaultValues = [NSUserDefaults defaultsFromSettingsBundle];
    
    //default folders
    //names should be unique across all folders
    
    Folder *inbox = [Folder folderWithName:@"Documents" 
                           predicateString:nil 
                           sortDescriprors:nil 
                                entityName:nil 
                                  iconName:@"ButtonDocuments.png"];
    inbox.filters = [NSArray arrayWithObjects: 
                     [Folder folderWithName:@"Resolutions"
                            predicateString:@"(status == 0 || status == 1)"
                            sortDescriprors:[NSArray arrayWithObjects:
                                             [[[NSSortDescriptor alloc] initWithKey:@"receivedStripped" ascending:NO] autorelease],
                                             [[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES] autorelease],
                                             [[[NSSortDescriptor alloc] initWithKey:@"received" ascending:NO] autorelease],
                                             nil] 
                                 entityName:@"DocumentResolution"
                                   iconName:@"ButtonResolution.png"],
                     [Folder folderWithName:@"Signatures"
                            predicateString:@"(status == 0 || status == 1)"
                            sortDescriprors:[NSArray arrayWithObjects:
                                             [[[NSSortDescriptor alloc] initWithKey:@"receivedStripped" ascending:NO] autorelease],
                                             [[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES] autorelease],
                                             [[[NSSortDescriptor alloc] initWithKey:@"received" ascending:NO] autorelease],
                                             nil] 
                                 entityName:@"DocumentSignature"
                                   iconName:@"ButtonSignature.png"],
                     nil];
    
    Folder *archive = [Folder folderWithName:@"Archive"
                             predicateString:nil 
                             sortDescriprors:nil 
                                  entityName:nil 
                                    iconName:@"ButtonArchive.png"];
    archive.filters = [NSArray arrayWithObjects: 
                       [Folder folderWithName:@"Resolutions"
                              predicateString:@"!(status == 0 || status == 1)"
                              sortDescriprors:[NSArray arrayWithObject:
                                               [[[NSSortDescriptor alloc] initWithKey:@"dateStripped" ascending:NO] autorelease]
                                               ] 
                                   entityName:@"DocumentResolution"
                                     iconName:@"ButtonResolution.png"], 
                       [Folder folderWithName:@"Signatures"
                              predicateString:@"!(status == 0 || status == 1)"
                              sortDescriprors:[NSArray arrayWithObject:
                                               [[[NSSortDescriptor alloc] initWithKey:@"dateStripped" ascending:NO] autorelease] 
                                              ] 
                                   entityName:@"DocumentSignature"
                                     iconName:@"ButtonSignature.png"],
                       nil];
    
    NSArray* defaultFolders = [NSArray arrayWithObjects:
                               inbox,
                               archive,
                               nil];
    [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:defaultFolders] forKey:@"folders"];
    
    [defaultValues setObject:@"archive" forKey:@"serverDatabaseViewArchive"];
    [defaultValues setObject:@"inbox" forKey:@"serverDatabaseViewInbox"];
    
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
    
	if ([currentDefaults boolForKey:@"localRemoveAll"])
	{
		[self purgeData];
		[currentDefaults setBool:NO forKey:@"localRemoveAll"];
	}
	else
		[[DataSource sharedDataSource] initDatabase];
	
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

#warning remove it when drops iOS3
- (void)applicationWillTerminate:(UIApplication *)application {

	
	[[NSNotificationCenter defaultCenter] postNotificationName: @"ApplicationMayTerminateNotification" object: nil];

    [syncTimer invalidate]; syncTimer = nil;
    
    DataSource *ds = [DataSource sharedDataSource];

    NSUInteger unreadCount = [ds countUnreadDocuments];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];

    [ds shutdown];
    
    [[AZZLogger sharedAZZLogger] removeLogFile];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] postNotificationName: @"ApplicationMayTerminateNotification" object: nil];

    DataSource *ds = [DataSource sharedDataSource];
	
    NSUInteger unreadCount = [ds countUnreadDocuments];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];

	[currentDefaults synchronize];

	if ([currentDefaults boolForKey:@"localRemoveAll"])
	{
		[self purgeData];
		[currentDefaults setBool:NO forKey:@"localRemoveAll"];
	}
}

- (void)dealloc 
{

    self.window = nil;
    self.rootViewController = nil;
    [syncTimer invalidate]; [syncTimer release]; syncTimer = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL canceled = (buttonIndex == 0);
    
    if (!canceled)
    {
		[[DataSource sharedDataSource] purgeDatabase];
		
		[[DataSource sharedDataSource] initDatabase];
    }
}

#pragma mark Private
-(void) purgeData
{
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purge local data", "Purge local data")
													 message:NSLocalizedString(@"Do really want purge all local data?", "Do really want purge all local data?")
													delegate:self 
										   cancelButtonTitle:NSLocalizedString(@"Cancel", "Cancel")
										   otherButtonTitles:NSLocalizedString(@"OK", "OK"),
						   nil];
	[prompt show];
	
	[prompt release];
}
@end