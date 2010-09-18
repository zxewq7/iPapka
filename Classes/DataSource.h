//
//  DataSource.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 20.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LNDataSource.h"

@class Folder, Document, DocumentManaged;

@interface DataSource : NSObject<LNDataSourceDelegate, UIAlertViewDelegate>
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel         *managedObjectModel;
    NSManagedObjectContext       *managedObjectContext;
    NSMutableDictionary          *dataSources;
    NSNotificationCenter         *notify;
    NSEntityDescription          *documentEntityDescription;
    NSPredicate                  *documentUidPredicateTemplate;
    NSEntityDescription          *personEntityDescription;
    NSPredicate                  *personUidPredicateTemplate;
    BOOL                         isSyncing;
}
+ (DataSource *)sharedDataSource;

@property (nonatomic, retain, readonly) NSEntityDescription *documentEntityDescription;
@property (nonatomic, retain, readonly) NSPredicate         *documentUidPredicateTemplate;
@property (nonatomic, retain, readonly) NSEntityDescription *personEntityDescription;
@property (nonatomic, retain, readonly) NSPredicate         *personUidPredicateTemplate;
@property (nonatomic)                   BOOL                isSyncing;
@property (nonatomic, retain, readonly) NSDate              *lastSynced;

-(NSArray *) documentsForFolder:(Folder *) folder;
-(void) refreshDocuments;
-(Document *) loadDocument:(DocumentManaged *) aDocument;
-(NSUInteger) countUnreadDocumentsForFolder:(Folder *) folder;
-(void) shutdown;
-(void) commit;
-(void) saveDocument:(Document *) aDocument;
-(void) archiveDocument:(DocumentManaged *) aDocument;
@end
