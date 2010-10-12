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
#import "Attachment.h"
#import "AttachmentPage.h"
#import "LNDocumentReader.h"
#import "DocumentResolution.h"
#import "DocumentSignature.h"
#import "Person.h"
#import "LNDocumentWriter.h"
#import "FileField.h"

static NSString* SyncingContext = @"SyncingContext";

@interface DataSource(Private)
- (LNDocumentWriter *) documentWriter;
- (LNDocumentReader *) documentReader;
- (NSEntityDescription *)documentEntityDescription;
- (NSEntityDescription *)personEntityDescription;
- (NSEntityDescription *)pageEntityDescription;
- (NSPredicate *)documentUidPredicateTemplate;
- (NSPredicate *)personUidPredicateTemplate;
- (NSManagedObjectModel *)managedObjectModel;
@end

@implementation DataSource
SYNTHESIZE_SINGLETON_FOR_CLASS(DataSource);


@synthesize isSyncing;

static NSString * const kDocumentUidSubstitutionVariable = @"UID";
static NSString * const kPersonUidSubstitutionVariable = @"UID";

#pragma mark -
#pragma mark properties


-(NSDate *) lastSynced
{
    NSData *lastSynced = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSynced"];
    if (lastSynced != nil)
        return [NSKeyedUnarchiver unarchiveObjectWithData:lastSynced];
    return nil;
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
        
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
            [persistentStoreCoordinator release];
            persistentStoreCoordinator = nil;
            NSAssert1(NO, @"Unhandled to create persistentStoreCoordinator: %@", [error localizedDescription]);
        }
        
        if (persistentStoreCoordinator != nil) {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];
        }
    }
    return self;
}


#pragma mark -
#pragma mark methods
-(NSArray *) persons
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext]];
	
    NSSortDescriptor *sortDescriptor = 
    [[NSSortDescriptor alloc] initWithKey:@"last" 
                                ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] 
                                initWithObjects:sortDescriptor, nil];  
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
	
	NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    NSAssert1(fetchResults != nil, @"Unhandled error executing fetch folder content: %@", [error localizedDescription]);
    
    return fetchResults;    
}

-(NSFetchedResultsController *) documentsForFolder:(Folder *) folder
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:folder.entityName inManagedObjectContext:managedObjectContext]];
	
    NSPredicate *filter = folder.predicate;
    if (filter)
        [fetchRequest setPredicate:filter];
    
    NSSortDescriptor *sortDescriptor = 
    [[NSSortDescriptor alloc] initWithKey:@"strippedDateModified" 
                                ascending:NO];
    
    NSArray *sortDescriptors = [[NSArray alloc] 
                                initWithObjects:sortDescriptor, nil];  
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
	
    
    NSFetchedResultsController *fetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:@"strippedDateModified" 
                                                   cacheName:folder.name];
    [fetchRequest release];
    
    return [fetchedResultsController autorelease];
}

-(NSUInteger) countUnreadDocumentsForFolder:(Folder *) folder
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:folder.entityName inManagedObjectContext:managedObjectContext]];
	
    NSString *format = @"(isRead==nil || isRead==NO)";
    if (folder.predicateString)
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
    isNeedFetchFromServer = YES;
    [[self documentWriter] sync];
}


-(void) shutdown
{
    [self commit];
}

-(void)commit
{
    NSError *error = nil;
    NSSet *updatedObjects = [managedObjectContext updatedObjects];
    
    for (NSManagedObject *object in updatedObjects)
    {
        NSDictionary *changedValues = [object changedValues];
        NSUInteger numberOfProperties = [changedValues count];
        if ([changedValues objectForKey: @"syncStatus"]) //ignore objects with changed sync status
            continue;

        if ([object isKindOfClass:[Document class]])
        {
            
            if ([changedValues objectForKey: @"isRead"]) //ignore these properties
                numberOfProperties--;
            
            if (numberOfProperties > 0) //set syncStatus to SyncStatusNeedSyncToServer
                [object setValue:[NSNumber numberWithInt:SyncStatusNeedSyncToServer] forKey:@"syncStatus"];
                
        }
        else if ([object isKindOfClass:[FileField class]])

        {
            [object setValue:[NSNumber numberWithInt:SyncStatusNeedSyncToServer] forKey:@"syncStatus"];
        }
    }

    NSSet *deletedObjects = [managedObjectContext deletedObjects];
    NSFileManager *df = [NSFileManager defaultManager];
    
    for (NSManagedObject *object in deletedObjects)
    {
        NSString *path = nil;
        if ([object isKindOfClass:[Document class]])
            path = [object valueForKey:@"path"];
        else if ([object isKindOfClass:[Attachment class]])
            path = [object valueForKey:@"path"];
        else if ([object isKindOfClass:[AttachmentPage class]])
            path = [object valueForKey:@"path"];
        
        if (path)
            [df removeItemAtPath:path error:NULL];
    }

    if (![managedObjectContext save:&error])
    {
        NSAssert1(NO, @"Unhandled error executing commit: %@", [error localizedDescription]);
    }
}

#pragma mark -
#pragma mark LNDocumentReaderDataSource
- (Document *) documentReader:(LNDocumentReader *) documentReader documentWithUid:(NSString *) anUid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:self.documentEntityDescription];
    NSPredicate *predicate = [self.documentUidPredicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:anUid forKey:kDocumentUidSubstitutionVariable]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    NSAssert1(fetchResults != nil, @"Unhandled error executing document fetch: %@", [error localizedDescription]);
    
    if ([fetchResults count] > 0)
        return [fetchResults objectAtIndex:0];
    
    return nil;
}

- (DocumentResolution *) documentReaderCreateResolution:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentResolution" inManagedObjectContext:managedObjectContext];
}

- (DocumentSignature *) documentReaderCreateSignature:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentSignature" inManagedObjectContext:managedObjectContext];
}

- (Document *) documentReaderCreateDocument:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Document" inManagedObjectContext:managedObjectContext];
}

- (Attachment *) documentReaderCreateAttachment:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Attachment" inManagedObjectContext:managedObjectContext];    
}

- (AttachmentPage *) documentReaderCreatePage:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"AttachmentPage" inManagedObjectContext:managedObjectContext];
}

- (ResolutionAudio *) documentReaderCreateResolutionAudio:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"ResolutionAudio" inManagedObjectContext:managedObjectContext];
}

- (SignatureAudio *) documentReaderCreateSignatureAudio:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"SignatureAudio" inManagedObjectContext:managedObjectContext];
}

- (AttachmentPageDrawings *) documentReaderCreateAttachmentPageDrawings:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"AttachmentPageDrawings" inManagedObjectContext:managedObjectContext];
}

- (NSSet *) documentReaderRootUids:(LNDocumentReader *) documentReader
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:self.documentEntityDescription];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == nil"];
    [request setPredicate:predicate];

    
    [request setPropertiesToFetch :[NSArray arrayWithObject:@"uid"]];

    // Execute the fetch.
    NSError *error;

    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];

    NSAssert1(fetchResults != nil, @"Unhandled error executing document fetch: %@", [error localizedDescription]);
    
    NSMutableSet * result = [NSMutableSet setWithCapacity: [fetchResults count]];
    for (NSDictionary *doc in fetchResults)
        [result addObject: [doc objectForKey: @"uid"]];

    return result;
}

- (void) documentReader:(LNDocumentReader *) documentReader removeObject:(NSManagedObject *) object;
{
    [managedObjectContext deleteObject:object];
}

- (void) documentReaderCommit:(LNDocumentReader *) documentReader
{
    [self commit];
}

- (Person *) documentReader:(LNDocumentReader *) documentReader personWithUid:(NSString *) anUid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:self.personEntityDescription];
    NSPredicate *predicate = [self.personUidPredicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:anUid forKey:kPersonUidSubstitutionVariable]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    NSAssert1(fetchResults != nil, @"Unhandled error executing person fetch: %@", [error localizedDescription]);
    
    if ([fetchResults count] > 0)
        return [fetchResults objectAtIndex:0];
#warning fake or incorrect data
    else
    {
        Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:managedObjectContext];
        person.uid = anUid;
        NSArray *chunks = [anUid componentsSeparatedByString: @" "];
        person.first = [anUid substringToIndex:1];
        person.middle = [anUid substringToIndex:1];
        person.last = [chunks objectAtIndex: 0];
        NSLog(@"Created person: %@", anUid);
        return person;
    }
}

- (NSArray *) documentReaderUnfetchedResources:(LNDocumentReader *) documentReader
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:self.pageEntityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFetched == NO"];

    [request setPredicate:predicate];
    
    // Execute the fetch.
    NSError *error;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    NSAssert1(fetchResults != nil, @"Unhandled error executing unfetched pages fetch: %@", [error localizedDescription]);
    
    return fetchResults;    
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [documentReader release];
    [documentEntityDescription release];
    [personEntityDescription release];
    [documentUidPredicateTemplate release];
    [pageEntityDescription release];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [documentReader removeObserver:self
                        forKeyPath:@"isSyncing"];

    [documentReader release]; documentReader = nil;
    
    [documentWriter removeObserver:self
                        forKeyPath:@"isSyncing"];
    [documentWriter release]; documentWriter = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &SyncingContext)
    {
        if (isNeedFetchFromServer && !documentWriter.isSyncing)
        {
            [[self documentReader] refreshDocuments];
            isNeedFetchFromServer = NO;
            return;
        }
        
        self.isSyncing = documentReader.isSyncing || documentWriter.isSyncing;
        
        if (!self.isSyncing)
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSDate date]] forKey: @"lastSynced"];
        
        if (!self.isSyncing && documentReader.hasErrors)
        {
            UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Synchronization error", "Synchronization error")
                                                             message:@"Unable to synchronyze"
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"OK", "OK")
                                                   otherButtonTitles:nil];
            [prompt show];
            [prompt release];            
        }
            
        
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
@end

@implementation DataSource(Private)
- (LNDocumentReader *) documentReader
{
    if (!documentReader)
    {
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSString *serverUrl = [currentDefaults objectForKey:@"serverUrl"];
        NSString *serverDatabaseViewInbox = [currentDefaults objectForKey:@"serverDatabaseViewInbox"];
        NSString *serverDatabaseViewArchive = [currentDefaults objectForKey:@"serverDatabaseViewArchive"];
        
        documentReader = [[LNDocumentReader alloc] initWithUrl:serverUrl andViews:[NSArray arrayWithObjects: serverDatabaseViewInbox, serverDatabaseViewArchive, nil]];
        
        documentReader.dataSource = self;
        
        [documentReader addObserver:self
                         forKeyPath:@"isSyncing"
                            options:0
                            context:&SyncingContext];
    }
    
    return documentReader;
}

- (LNDocumentWriter *) documentWriter
{
    if (!documentWriter)
    {
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSString *serverUrl = [currentDefaults objectForKey:@"serverUrl"];
        documentWriter = [[LNDocumentWriter alloc] initWithUrl: serverUrl];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext]];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"syncStatus==%d", SyncStatusNeedSyncToServer]];

        NSSortDescriptor *sortDescriptor = 
        [[NSSortDescriptor alloc] initWithKey:@"dateModified" 
                                    ascending:NO];
        
        NSArray *sortDescriptors = [[NSArray alloc] 
                                    initWithObjects:sortDescriptor, nil];  
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        [sortDescriptor release];

        
        NSFetchedResultsController *fetchedResultsController = 
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                            managedObjectContext:managedObjectContext 
                                              sectionNameKeyPath:nil
                                                       cacheName:@"UnsyncedDocuments"];
        [fetchRequest release];
        
        documentWriter.unsyncedDocuments = fetchedResultsController;
        
        [fetchedResultsController release];
        

        fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"FileField" inManagedObjectContext:managedObjectContext]];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"syncStatus==%d", SyncStatusNeedSyncToServer]];
        
        sortDescriptor = 
        [[NSSortDescriptor alloc] initWithKey:@"dateModified" 
                                    ascending:NO];
        
        sortDescriptors = [[NSArray alloc] 
                                    initWithObjects:sortDescriptor, nil];  
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        [sortDescriptor release];

        
        fetchedResultsController = 
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                            managedObjectContext:managedObjectContext 
                                              sectionNameKeyPath:nil
                                                       cacheName:@"UnsyncedFiles"];
        [fetchRequest release];
        
        documentWriter.unsyncedFiles = fetchedResultsController;
        
        [fetchedResultsController release];
        
        
        [documentWriter addObserver:self
                         forKeyPath:@"isSyncing"
                            options:0
                            context:&SyncingContext];

    }
    return documentWriter;
}

- (NSEntityDescription *)documentEntityDescription 
{
    if (documentEntityDescription == nil) {
        documentEntityDescription = [[NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext] retain];
    }
    return documentEntityDescription;
}

- (NSEntityDescription *)personEntityDescription 
{
    if (personEntityDescription == nil) {
        personEntityDescription = [[NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext] retain];
    }
    return personEntityDescription;
}
- (NSEntityDescription *)pageEntityDescription 
{
    if (pageEntityDescription == nil) {
        pageEntityDescription = [[NSEntityDescription entityForName:@"AttachmentPage" inManagedObjectContext:managedObjectContext] retain];
    }
    return pageEntityDescription;
}

- (NSPredicate *)documentUidPredicateTemplate 
{
    if (documentUidPredicateTemplate == nil) {
        NSExpression *leftHand = [NSExpression expressionForKeyPath:@"uid"];
        NSExpression *rightHand = [NSExpression expressionForVariable:kDocumentUidSubstitutionVariable];
        documentUidPredicateTemplate = [[NSComparisonPredicate alloc] initWithLeftExpression:leftHand rightExpression:rightHand modifier:NSDirectPredicateModifier type:NSLikePredicateOperatorType options:0];
    }
    return documentUidPredicateTemplate;
}

- (NSPredicate *)personUidPredicateTemplate 
{
    if (personUidPredicateTemplate == nil) {
        NSExpression *leftHand = [NSExpression expressionForKeyPath:@"uid"];
        NSExpression *rightHand = [NSExpression expressionForVariable:kPersonUidSubstitutionVariable];
        personUidPredicateTemplate = [[NSComparisonPredicate alloc] initWithLeftExpression:leftHand rightExpression:rightHand modifier:NSDirectPredicateModifier type:NSLikePredicateOperatorType options:0];
    }
    return personUidPredicateTemplate;
}

- (NSManagedObjectModel *)managedObjectModel 
{
    
    if (managedObjectModel == nil)
    {
        managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
        
        // Find the fetched properties, and make them sorted...
        for (NSEntityDescription *entity in [managedObjectModel entities]) 
        {
            for (NSPropertyDescription *property in [entity properties]) 
            {
                if ([property isKindOfClass:[NSFetchedPropertyDescription class]]) 
                {
                    NSFetchedPropertyDescription *fetchedProperty = (NSFetchedPropertyDescription *)property;
                    NSFetchRequest *fetchRequest = [fetchedProperty fetchRequest];
                    NSSortDescriptor *sort = nil;
                    if ([[property name] isEqualToString:@"attachmentsOrdered"])
                        sort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
                    else if ([[property name] isEqualToString:@"linksOrdered"])
                        sort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
                    else if ([[property name] isEqualToString:@"pagesOrdered"])
                        sort = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
                    
                    if (sort)
                        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
                    
                    [sort release];

                }
            }
        }
    }
    return managedObjectModel;
}
@end
