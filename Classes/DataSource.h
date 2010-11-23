//
//  DataSource.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 20.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LNDocumentReader.h"
#import "LNPersonReader.h"

#define kDocumentFlowDeleted @"documentFlowDeleted"
#define kDocumentFlowUpdated @"documentFlowUpdated"

@class Folder, DocumentRoot, LNDocumentWriter, LNSettingsReader;

@interface DataSource : NSObject<LNDocumentReaderDataSource, LNPersonReaderDataSource>
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel         *managedObjectModel;
    NSManagedObjectContext       *managedObjectContext;
    NSNotificationCenter         *notify;
    NSEntityDescription          *documentEntityDescription;
    NSPredicate                  *documentUidPredicateTemplate;
    NSEntityDescription          *personEntityDescription;
    NSEntityDescription          *fileEntityDescription;
    NSEntityDescription          *pageEntityDescription;
    NSPredicate                  *personUidPredicateTemplate;
    BOOL                         isSyncing;
    NSMutableArray               *readers;
    int                          syncStep;
    BOOL                         showErrors;
}
+ (DataSource *)sharedDataSource;
@property (nonatomic)           BOOL    isSyncing;
@property (nonatomic, readonly) NSDate  *lastSynced;
@property (nonatomic, readonly) NSArray *folders;

-(NSFetchedResultsController *) documentsForFolder:(Folder *) folder;
-(void) sync:(BOOL) showErrors;
-(NSUInteger) countUnreadDocumentsForFolder:(Folder *) folder;
-(NSUInteger) countUnreadDocuments;
-(void) shutdown;
-(void) commit;
-(NSFetchedResultsController *) persons;
@end
