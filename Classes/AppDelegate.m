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
@synthesize window, rootViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![currentDefaults objectForKey:@"lastFolder"])
    {
        //Create dictionary
        NSMutableDictionary* defaultValues = [NSUserDefaults defaultsFromSettingsBundle];
        
        //default folders
        Folder *inbox = [Folder folderWithName:@"Documents" 
                               predicateString:@"dataSourceId = \"inbox\"" 
                                    entityName:@"Document"
                                      iconName:@"ButtonDocuments.png"];
        inbox.filters = [NSArray arrayWithObjects: 
                         [Folder folderWithName:@"Resolutions" 
                                predicateString:@"dataSourceId = \"inbox\"" 
                                     entityName:@"Resolution"
                                       iconName:@"ButtonResolution.png"], 
                         [Folder folderWithName:@"Signatures" 
                                predicateString:@"dataSourceId = \"inbox\"" 
                                     entityName:@"Signature"
                                       iconName:@"ButtonSignature.png"],
                         nil];
        
        Folder *archive = [Folder folderWithName:@"Archive" 
                                 predicateString:@"dataSourceId = \"archive\"" 
                                      entityName:@"Document"
                                        iconName:@"ButtonArchive.png"];
        
        archive.filters = [NSArray arrayWithObjects: 
                           [Folder folderWithName:@"Resolutions" 
                                  predicateString:@"dataSourceId = \"archive\"" 
                                       entityName:@"Resolution"
                                         iconName:@"ButtonResolution.png"], 
                           [Folder folderWithName:@"Signatures" 
                                  predicateString:@"dataSourceId = \"archive\"" 
                                       entityName:@"Signature"
                                         iconName:@"ButtonSignature.png"],
                           nil];
        
        NSArray* defaultFolders = [NSArray arrayWithObjects:
                                   inbox,
                                   archive,
                                   nil];
        [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:defaultFolders] forKey:@"folders"];
        [defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:inbox] forKey:@"lastFolder"];
        
        [defaultValues setObject:@"ProcessedRest" forKey:@"serverDatabaseViewArchive"];
        [defaultValues setObject:@"documents" forKey:@"serverDatabaseViewInbox"];
        
        //Register the dictionary of defaults
        
        
        [currentDefaults registerDefaults:defaultValues];
        [currentDefaults synchronize];
    }
    
    NSData *lastFolderData = [currentDefaults objectForKey:@"lastFolder"];
    Folder *lastFolder;
    if (lastFolderData != nil)
        lastFolder = [NSKeyedUnarchiver unarchiveObjectWithData:lastFolderData];
    
    self.rootViewController.folder = lastFolder;
    [self.window addSubview:rootViewController.view];
    [self.window makeKeyAndVisible];
#warning disabled refresh at startup
//    [[DataSource sharedDataSource] refreshDocuments];
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
    self.rootViewController = nil;
    [super dealloc];
}
@end