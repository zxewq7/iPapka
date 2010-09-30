//
//  DataSource.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 20.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LNDocumentReader.h"

@class Folder, Document, DocumentManaged, LNDocumentSaver, LNDocumentReader;

@interface DataSource : NSObject<UIAlertViewDelegate, LNDocumentReaderDataSource>
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel         *managedObjectModel;
    NSManagedObjectContext       *managedObjectContext;
    NSNotificationCenter         *notify;
    NSEntityDescription          *documentEntityDescription;
    NSPredicate                  *documentUidPredicateTemplate;
    NSEntityDescription          *personEntityDescription;
    NSEntityDescription          *pageEntityDescription;
    NSPredicate                  *personUidPredicateTemplate;
    BOOL                         isSyncing;
    LNDocumentSaver              *documentSaver;
    LNDocumentReader             *documentReader;
    NSUInteger                   countDocumentsToSend;
    BOOL                         isNeedFetchFromServer;
}
+ (DataSource *)sharedDataSource;
@property (nonatomic)                   BOOL                isSyncing;
@property (nonatomic, retain, readonly) NSDate              *lastSynced;

-(NSFetchedResultsController *) documentsForFolder:(Folder *) folder;
-(void) refreshDocuments;
-(NSUInteger) countUnreadDocumentsForFolder:(Folder *) folder;
-(void) shutdown;
-(void) commit;
-(NSArray *) persons;
@end
