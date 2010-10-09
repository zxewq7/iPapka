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
    //redirect NSLog to file
    //http://blog.coriolis.ch/2009/01/09/redirect-nslog-to-a-file-on-the-iphone/

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    if (documentsDirectory)
    {
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
        freopen([logPath cStringUsingEncoding:NSUTF8StringEncoding],"w+",stderr);
    }
    else
        NSLog(@"Unable to redirect log to file");
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![currentDefaults objectForKey:@"lastFolder"])
    {
        //Create dictionary
        NSMutableDictionary* defaultValues = [NSUserDefaults defaultsFromSettingsBundle];
        
        //default folders
        //names should be unique across all folders
        Folder *inbox = [Folder folderWithName:@"Documents" 
                               predicateString:@"parent==nil && status == 0" 
                                    entityName:@"Document"
                                      iconName:@"ButtonDocuments.png"];
        inbox.filters = [NSArray arrayWithObjects: 
                         [Folder folderWithName:@"Resolutions" 
                                predicateString:@"parent==nil && status == 0" 
                                     entityName:@"DocumentResolution"
                                       iconName:@"ButtonResolution.png"], 
                         [Folder folderWithName:@"Signatures" 
                                predicateString:@"parent==nil && status == 0" 
                                     entityName:@"DocumentSignature"
                                       iconName:@"ButtonSignature.png"],
                         nil];
        
        Folder *archive = [Folder folderWithName:@"Archive" 
                                 predicateString:@"parent==nil && status != 0" 
                                      entityName:@"Document"
                                        iconName:@"ButtonArchive.png"];
        
        archive.filters = [NSArray arrayWithObjects: 
                           [Folder folderWithName:@"Archived resolutions" 
                                  predicateString:@"parent==nil && status != 0" 
                                       entityName:@"DocumentResolution"
                                         iconName:@"ButtonResolution.png"], 
                           [Folder folderWithName:@"Archived signatures" 
                                  predicateString:@"parent==nil && status != 0" 
                                       entityName:@"DocumentSignature"
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
    Folder *lastFolder = nil;
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