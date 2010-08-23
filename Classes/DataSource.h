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

@class Folder, Document, DocumentManaged, LNDataSource;

@interface DataSource : NSObject<LNDataSourceDelegate>
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel         *managedObjectModel;
    NSManagedObjectContext       *managedObjectContext;
    LNDataSource                 *lnDataSource;
    NSNotificationCenter         *notify;
    NSEntityDescription          *documentEntityDescription;
    NSPredicate                  *documentUidPredicateTemplate;
    BOOL                         isSyncing;
}
+ (DataSource *)sharedDataSource;

@property (nonatomic, retain, readonly) NSEntityDescription *documentEntityDescription;
@property (nonatomic, retain, readonly) NSPredicate         *documentUidPredicateTemplate;
@property (nonatomic)                   BOOL                isSyncing;

-(NSArray *) documentsForFolder:(Folder *) folder;
-(void) refreshDocuments;
-(Document *) loadDocument:(DocumentManaged *) aDocument;
-(NSUInteger) countUnreadDocumentsForFolder:(Folder *) folder;
-(void) shutdown;
-(void) commit;
@end
