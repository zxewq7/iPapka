//
//  DataSource.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 20.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataSource.h"
#import "Folder.h"
#import "SynthesizeSingleton.h"
#import "Document.h"
#import "LNDataSource.h"

@interface DataSource(Private)
-(Document *) findDocumentByUid:(NSString *) anUid;
-(void) commit;
@end

@implementation DataSource
SYNTHESIZE_SINGLETON_FOR_CLASS(DataSource);
#pragma mark -
#pragma mark properties

- (NSEntityDescription *)documentEntityDescription {
    if (documentEntityDescription == nil) {
        documentEntityDescription = [[NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext] retain];
    }
    return documentEntityDescription;
}

static NSString * const kDocumentUidSubstitutionVariable = @"UID";

- (NSPredicate *)documentUidPredicateTemplate {
    if (documentUidPredicateTemplate == nil) {
        NSExpression *leftHand = [NSExpression expressionForKeyPath:@"uid"];
        NSExpression *rightHand = [NSExpression expressionForVariable:kDocumentUidSubstitutionVariable];
        documentUidPredicateTemplate = [[NSComparisonPredicate alloc] initWithLeftExpression:leftHand rightExpression:rightHand modifier:NSDirectPredicateModifier type:NSLikePredicateOperatorType options:0];
    }
    return documentUidPredicateTemplate;
}

#pragma mark -
#pragma mark Initialization

-(id)init
{
    if ((self = [super init])) {
        notify = [NSNotificationCenter defaultCenter];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

        NSURL *storeUrl = [NSURL fileURLWithPath: [basePath stringByAppendingPathComponent: @"Documents.sqlite"]];
        
        NSError *error;
        
        managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
        
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
            [persistentStoreCoordinator release];
            persistentStoreCoordinator = nil;
        }
        
        if (persistentStoreCoordinator != nil) {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];
        }
        lnDataSource = [[LNDataSource alloc] init];
#warning test settings        
        lnDataSource.host = @"http://127.0.0.1/~vovasty";
        lnDataSource.databaseReplicaId = @"C325777C0045161D";
        lnDataSource.viewReplicaId = @"89FB7FB8A9330311C325777C004EEFC8";
        lnDataSource.delegate = self;
        [lnDataSource loadCache];
        
        [[NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext] retain];
        
    }
    return self;
}
#pragma mark -
#pragma mark LNDataSourceDelegate
- (void) documentUpdated:(Document *) aDocument
{
    Document *foundDocument = [self findDocumentByUid:aDocument.uid];
    if (foundDocument) 
    {
        foundDocument.date = aDocument.date;
        foundDocument.dateModified = aDocument.dateModified;
        foundDocument.author = aDocument.author;
        foundDocument.title = aDocument.title;
        
        [self commit];
        
        [notify postNotificationName:@"DocumentUpdated" object:foundDocument];
    }
    else
        [self documentAdded:aDocument];
}

- (void) documentsDeleted:(NSArray *) documents
{
    NSMutableArray *documentsToDelete = [NSMutableArray arrayWithCapacity:[documents count]];
    for (Document *document in documents) 
    {
        Document *foundDocument = [self findDocumentByUid:document.uid];
        [documentsToDelete addObject:foundDocument];
        if (foundDocument)
            [managedObjectContext deleteObject:(NSManagedObject *)foundDocument];
    }
    
    [notify postNotificationName:@"DocumentsRemoved" object:documentsToDelete];
    
    [self commit];
}

- (void) documentAdded:(Document *) aDocument
{
    NSManagedObject *newDocument = [NSEntityDescription insertNewObjectForEntityForName:@"Document" inManagedObjectContext:managedObjectContext];
    
    [newDocument setValue:aDocument.date forKey:@"date"];
    [newDocument setValue:aDocument.dateModified forKey:@"dateModified"];
    [newDocument setValue:aDocument.author forKey:@"author"];
    [newDocument setValue:aDocument.title forKey:@"title"];
    [newDocument setValue:aDocument.uid forKey:@"uid"];
    
	[self commit];
    
        //    [newDocument release];
	
    [notify postNotificationName:@"DocumentAdded" object:aDocument];
}

- (void) documentsListDidRefreshed:(id) sender
{
    [notify postNotificationName:@"DocumentsListDidRefreshed" object:nil];
}

- (void) documentsListWillRefreshed:(id) sender
{
    [notify postNotificationName:@"DocumentsListWillRefreshed" object:nil];
}


#pragma mark -
#pragma mark methods
-(NSArray *) documentsForFolder:(Folder *) folder
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:self.documentEntityDescription];
	
        //    [fetchRequest setPredicate:folder.predicate];
	
	NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    NSAssert1(fetchResults != nil, @"Unhandled error executing document update: %@", [error localizedDescription]);

    return fetchResults;
}
-(void) refreshDocuments
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:self.documentEntityDescription];
	
    [lnDataSource refreshDocuments];
}
-(Document *) loadDocument:(Document *) aDocument
{
    return [lnDataSource loadDocument:aDocument.uid];
}
-(void) shutdown
{
    [self commit];
}
#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [lnDataSource release];
    [documentEntityDescription release];
    [documentUidPredicateTemplate release];

	[super dealloc];
}
@end

@implementation DataSource(Private)
-(Document *) findDocumentByUid:(NSString *) anUid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:self.documentEntityDescription];
    NSPredicate *predicate = [self.documentUidPredicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:anUid forKey:kDocumentUidSubstitutionVariable]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    NSAssert1(fetchResults != nil, @"Unhandled error executing document update: %@", [error localizedDescription]);
    
    if ([fetchResults count] > 0)
        return [fetchResults objectAtIndex:0];
    
    return nil;
}
-(void)commit
{
    NSError *error = nil;
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
    {
            //remove documents from cache for consistency
        NSSet *insertedObjects  = [managedObjectContext insertedObjects];
        for (Document *document in insertedObjects)
            [lnDataSource deleteDocument:document.uid];

        NSSet *updatedObjects  = [managedObjectContext updatedObjects];
        for (Document *document in updatedObjects)
            [lnDataSource deleteDocument:document.uid];
        
        NSAssert1(NO, @"Unhandled error executing commit: %@", [error localizedDescription]);
    }
}
@end
