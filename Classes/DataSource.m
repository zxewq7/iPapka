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
#import "LNDocumentReader.h"
#import "DocumentResolution.h"
#import "Signature.h"
#import "KeychainItemWrapper.h"
#import "Person.h"
#import "LNDocumentWriter.h"

#define kLoginFieldTag 1001
#define kPasswordFieldTag 1002

static NSString* SyncingContext = @"SyncingContext";

@interface DataSource(Private)
- (void) askLoginAndPassword:(NSString*) login;
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
	
    NSString *filterString = folder.predicateString;
    if (filterString)
        filterString = [filterString stringByAppendingString:@" && parent == nil"];
    else
        filterString = @"parent==nil";
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat: filterString]];
    
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

- (Signature *) documentReaderCreateSignature:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Signature" inManagedObjectContext:managedObjectContext];
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
    NSAssert1(fetchResults != nil, @"Unhandled error executing unfetched pages fetch: %@", [error localizedDescription]);
    
    return fetchResults;    
}
#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        exit(0);
    else
    {
        UITextField *loginField = (UITextField *)[alertView viewWithTag:kLoginFieldTag];
        UITextField *passwordField = (UITextField *)[alertView viewWithTag:kPasswordFieldTag];
        NSString *login = loginField.text;
        NSString *password = passwordField.text;
        if (!login || !password || [login isEqualToString:@""] || [password isEqualToString:@""]) 
        {
            [self askLoginAndPassword:password];
            return;
        }
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
        [wrapper setObject:login forKey: (NSString *)kSecAttrAccount];
        [wrapper setObject:password forKey: (NSString *)kSecValueData];
        [wrapper release];
        
        
        [self documentReader].login = login;
        [self documentReader].password = password;
    }
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
        
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
        
        NSString *login = [wrapper objectForKey:(NSString *)kSecAttrAccount];
        NSString *password = [wrapper objectForKey:(NSString *)kSecValueData];
        
        [wrapper release];
        
        [documentReader release];
        
        documentReader = [[LNDocumentReader alloc] initWithUrl:serverUrl andViews:[NSArray arrayWithObjects: serverDatabaseViewInbox, serverDatabaseViewArchive, nil]];
        
        documentReader.dataSource = self;
        
        documentReader.login = login;
        documentReader.password = password;
        
        [documentReader addObserver:self
                         forKeyPath:@"isSyncing"
                            options:0
                            context:&SyncingContext];
        
//        if (!login || !password || [login isEqualToString:@""] || [password isEqualToString:@""])
//            [self askLoginAndPassword:login];
    }
    
    return documentReader;
}

    //http://iphone-dev-tips.alterplay.com/2009/12/username-and-password-uitextfields-in.html
- (void) askLoginAndPassword:(NSString*) login
{
    UITextField *textField;
    UITextField *textField2;
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Username and password", "Username and password")
                                                     message:@"\n\n\n" // IMPORTANT
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"Quit", "login->Quit")
                                           otherButtonTitles:NSLocalizedString(@"Enter", "login->Enter"),
                                           nil];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)]; 
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setPlaceholder:NSLocalizedString(@"username", "username")];
    textField.text = login;
    textField.tag = kLoginFieldTag;
    [prompt addSubview:textField];
    
    textField2 = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 85.0, 260.0, 25.0)]; 
    [textField2 setBackgroundColor:[UIColor whiteColor]];
    [textField2 setPlaceholder:NSLocalizedString(@"password", "password")];
    [textField2 setSecureTextEntry:YES];
    textField2.tag = kPasswordFieldTag;
    [prompt addSubview:textField2];
    
        // set place
#warning next string obsoleted in iOS4
    [prompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
    
    [prompt show];
    [prompt release];
    
        // set cursor and show keyboard
    if (login && ![login isEqualToString:@""])
        [textField2 becomeFirstResponder];
    else
        [textField becomeFirstResponder];
}
- (LNDocumentWriter *) documentWriter
{
    if (!documentWriter)
    {
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSString *serverUrl = [currentDefaults objectForKey:@"serverUrl"];
        documentWriter = [[LNDocumentWriter alloc] initWithUrl: serverUrl];
        
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
        
        documentWriter.login = [wrapper objectForKey:(NSString *)kSecAttrAccount];
        documentWriter.password = [wrapper objectForKey:(NSString *)kSecValueData];
        
        [wrapper release];
        
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
                                                       cacheName:@"UnsyncedObjects"];
        [fetchRequest release];
        
        documentWriter.unsyncedDocuments = fetchedResultsController;
        
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
