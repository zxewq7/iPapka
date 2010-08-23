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
#import "DocumentManaged.h"
#import "Document.h"
#import "LNDataSource.h"
#import "ResolutionManaged.h"
#import "SignatureManaged.h"
#import "Resolution.h"
#import "Signature.h"


@interface DataSource(Private)
-(DocumentManaged *) findDocumentByUid:(NSString *) anUid;
-(void) commit;
-(void) createLNDatasourceFromDefaults;
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
        
        [self createLNDatasourceFromDefaults];
        
        [[NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext] retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(defaultsChanged:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}
#pragma mark -
#pragma mark LNDataSourceDelegate
- (void) documentUpdated:(Document *) aDocument
{
    DocumentManaged *foundDocument = [self findDocumentByUid:aDocument.uid];
    if (foundDocument) 
    {
        foundDocument.date = aDocument.date;
        foundDocument.dateModified = aDocument.dateModified;
        foundDocument.author = aDocument.author;
        foundDocument.title = aDocument.title;
        foundDocument.isRead = [NSNumber numberWithBool:NO];
        if ([aDocument isKindOfClass:[Signature class]])
        {
            
        }
        
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
        DocumentManaged *foundDocument = [self findDocumentByUid:document.uid];
        [documentsToDelete addObject:foundDocument];
        if (foundDocument)
            [managedObjectContext deleteObject:(NSManagedObject *)foundDocument];
    }
    
    [notify postNotificationName:@"DocumentsRemoved" object:documentsToDelete];
    
    [self commit];
}

- (void) documentAdded:(Document *) aDocument
{
    Document *newDocument = nil;
    BOOL isResolution = [aDocument isKindOfClass:[Resolution class]];
    if (isResolution)
         newDocument = [NSEntityDescription insertNewObjectForEntityForName:@"Resolution" inManagedObjectContext:managedObjectContext];
    else if ([aDocument isKindOfClass:[Signature class]])
         newDocument = [NSEntityDescription insertNewObjectForEntityForName:@"Signature" inManagedObjectContext:managedObjectContext];
    else 
        NSAssert1(NO,@"Unknown entity: %@", [[aDocument class] name]);
    
    newDocument.date = aDocument.date;
    newDocument.dateModified = aDocument.dateModified;
    newDocument.author = aDocument.author;
    newDocument.title = aDocument.title;
    newDocument.uid = aDocument.uid;
    newDocument.isRead = [NSNumber numberWithBool:NO];
    
    if (isResolution)
        ((ResolutionManaged *)newDocument).performers = ((Resolution *)aDocument).performers;
    
	[self commit];
    
        //    [newDocument release];
	
    [notify postNotificationName:@"DocumentAdded" object:newDocument];
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
	[fetchRequest setEntity:[NSEntityDescription entityForName:folder.entityName inManagedObjectContext:managedObjectContext]];
	
    NSPredicate *filter = folder.predicate;
    if (filter)
        [fetchRequest setPredicate:folder.predicate];
	
	NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    NSAssert1(fetchResults != nil, @"Unhandled error executing fetch folder content: %@", [error localizedDescription]);
    
    return fetchResults;
}

-(NSUInteger) countUnreadDocumentsForFolder:(Folder *) folder
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:folder.entityName inManagedObjectContext:managedObjectContext]];
	
    NSPredicate *filter = folder.predicate;
    NSString *format = @"isRead==NO";
    if (filter)
        format = [[format stringByAppendingString:@" && "] stringByAppendingString:folder.predicateString];

    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:format]];

	
	NSError *error = nil;
    NSUInteger count = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    NSAssert1(count != NSNotFound, @"Unhandled error executing count unread document: %@", [error localizedDescription]);
    
    return count;
}


-(void) refreshDocuments
{
    [lnDataSource refreshDocuments];
}
-(Document *) loadDocument:(DocumentManaged *) aDocument
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
-(DocumentManaged *) findDocumentByUid:(NSString *) anUid
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
        for (DocumentManaged *document in insertedObjects)
            [lnDataSource deleteDocument:document.uid];

        NSSet *updatedObjects  = [managedObjectContext updatedObjects];
        for (DocumentManaged *document in updatedObjects)
            [lnDataSource deleteDocument:document.uid];
        
        NSAssert1(NO, @"Unhandled error executing commit: %@", [error localizedDescription]);
    }
}

- (void)defaultsChanged:(NSNotification *)notif
{
        //purge cache - we need not it anymore
    [lnDataSource purgeCache];
    
    [self createLNDatasourceFromDefaults];
}

-(void) createLNDatasourceFromDefaults
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSString *serverHost = [currentDefaults objectForKey:@"serverHost"];
    NSString *serverDatabase = [currentDefaults objectForKey:@"serverDatabase"];
    NSString *serverDatabaseView = [currentDefaults objectForKey:@"serverDatabaseView"];
    NSString *serverAuthLogin = [currentDefaults objectForKey:@"serverAuthLogin"];
    NSString *serverAuthPassword = [currentDefaults objectForKey:@"serverAuthPassword"];
    
    LNDataSource *ds = [[LNDataSource alloc] init];
    ds.host = serverHost;
    ds.databaseReplicaId = serverDatabase;
    ds.viewReplicaId = serverDatabaseView;
    ds.login = serverAuthLogin;
    ds.password = serverAuthPassword;
    [ds loadCache];

    [lnDataSource release];
    lnDataSource = ds;

    lnDataSource.delegate = self;

}
@end
