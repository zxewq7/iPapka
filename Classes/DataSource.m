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
#import "KeychainItemWrapper.h"
#import "PersonManaged.h"

#define kLoginFieldTag 1001
#define kPasswordFieldTag 1002

@interface DataSource(Private)
- (DocumentManaged *) findDocumentByUid:(NSString *) anUid;
- (PersonManaged *) findPersonByUid:(NSString *) anUid;
- (void) createLNDatasourceFromDefaults;
- (void) askLoginAndPassword:(NSString*) login;
- (void) updatePerformers:(NSArray *) uids resolution:(ResolutionManaged *) resolution;
- (void) updateAuthor:(NSString *) uid document:(DocumentManaged *) document;
@end

@implementation DataSource
@synthesize isSyncing;

SYNTHESIZE_SINGLETON_FOR_CLASS(DataSource);
#pragma mark -
#pragma mark properties

- (NSEntityDescription *)documentEntityDescription {
    if (documentEntityDescription == nil) {
        documentEntityDescription = [[NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext] retain];
    }
    return documentEntityDescription;
}

- (NSEntityDescription *)personEntityDescription {
    if (documentEntityDescription == nil) {
        documentEntityDescription = [[NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext] retain];
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

static NSString * const kPersonUidSubstitutionVariable = @"UID";

- (NSPredicate *)personUidPredicateTemplate {
    if (personUidPredicateTemplate == nil) {
        NSExpression *leftHand = [NSExpression expressionForKeyPath:@"uid"];
        NSExpression *rightHand = [NSExpression expressionForVariable:kPersonUidSubstitutionVariable];
        personUidPredicateTemplate = [[NSComparisonPredicate alloc] initWithLeftExpression:leftHand rightExpression:rightHand modifier:NSDirectPredicateModifier type:NSLikePredicateOperatorType options:0];
    }
    return personUidPredicateTemplate;
}

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
        foundDocument.dateModified = aDocument.dateModified;
        [self updateAuthor:aDocument.author document:foundDocument];
        foundDocument.title = aDocument.title;
        foundDocument.isRead = [NSNumber numberWithBool:NO];
        if ([aDocument isKindOfClass:[Resolution class]])
        {
            ResolutionManaged *resolution = (ResolutionManaged *)aDocument;
            
            NSArray *performers = ((Resolution *)aDocument).performers;
            
            [self updatePerformers:performers resolution: resolution];
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
    DocumentManaged *newDocument = nil;
    BOOL isResolution = [aDocument isKindOfClass:[Resolution class]];
    if (isResolution)
         newDocument = [NSEntityDescription insertNewObjectForEntityForName:@"Resolution" inManagedObjectContext:managedObjectContext];
    else if ([aDocument isKindOfClass:[Signature class]])
         newDocument = [NSEntityDescription insertNewObjectForEntityForName:@"Signature" inManagedObjectContext:managedObjectContext];
    else 
        NSAssert1(NO,@"Unknown entity: %@", [[aDocument class] name]);
    
    newDocument.dateModified = aDocument.dateModified;
    [self updateAuthor:aDocument.author document:newDocument];
    newDocument.title = aDocument.title;
    newDocument.uid = aDocument.uid;
    newDocument.isRead = [NSNumber numberWithBool: [aDocument.dataSourceId isEqualToString: @"archive"]];
    newDocument.isArchived = [NSNumber numberWithBool:NO];
    newDocument.dataSourceId = aDocument.dataSourceId;
    newDocument.isEditable = [NSNumber numberWithBool: [@"inbox" isEqualToString:aDocument.dataSourceId]];
    
    if (isResolution)
    {
        ResolutionManaged *resolution = (ResolutionManaged *)newDocument;
        
        NSArray *performers = ((Resolution *)aDocument).performers;
        
        [self updatePerformers:performers resolution: resolution];
    }
    
	[self commit];
    
        //    [newDocument release];
	
    [notify postNotificationName:@"DocumentAdded" object:newDocument];
}

- (void) documentsListDidRefreshed:(id) sender
{
    isSyncing = NO;
    [notify postNotificationName:@"DocumentsListDidRefreshed" object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSDate date]] forKey: @"lastSynced"];
}

- (void) documentsListWillRefreshed:(id) sender
{
    isSyncing = YES;
    [notify postNotificationName:@"DocumentsListWillRefreshed" object:nil];
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

-(NSArray *) documentsForFolder:(Folder *) folder
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:folder.entityName inManagedObjectContext:managedObjectContext]];
	
    NSPredicate *filter = folder.predicate;
    if (filter)
        [fetchRequest setPredicate:folder.predicate];
    
    NSSortDescriptor *sortDescriptor = 
    [[NSSortDescriptor alloc] initWithKey:@"dateModified" 
                                ascending:NO];
    
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
    for (LNDataSource *ds in [dataSources allValues]) 
        [ds refreshDocuments];
}
-(Document *) loadDocument:(DocumentManaged *) aDocument
{
    LNDataSource *ds = [dataSources objectForKey:aDocument.dataSourceId];
    return [ds loadDocument:aDocument.uid];
}

-(void) saveDocument:(Document *) aDocument
{
    DocumentManaged *documentManaged = [self findDocumentByUid: aDocument.uid];
    documentManaged.isModifiedValue = YES;
    
    if ([aDocument isKindOfClass: [Resolution class]])
    {
        Resolution *resolution = (Resolution *) aDocument;
        ResolutionManaged *resolutionManaged = (ResolutionManaged *) documentManaged;
        
        //sync performers
        NSMutableArray *performers = [NSMutableArray arrayWithCapacity: [resolution.performers count]];
        for (PersonManaged *person in resolutionManaged.performers)
            [performers addObject: person.uid];
        
        resolution.performers = [performers count]?performers:nil;
    }
    
    [self commit];

    LNDataSource *ds = [dataSources objectForKey:aDocument.dataSourceId];
    [ds saveDocument:aDocument];
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
            //remove documents from cache for consistency
        NSSet *insertedObjects  = [managedObjectContext insertedObjects];
        for (DocumentManaged *document in insertedObjects)
        {
            LNDataSource *ds = [dataSources objectForKey:document.dataSourceId];
            [ds deleteDocument:document.uid];
        }
        
        NSSet *updatedObjects  = [managedObjectContext updatedObjects];
        for (DocumentManaged *document in updatedObjects)
        {
            LNDataSource *ds = [dataSources objectForKey:document.dataSourceId];
            [ds deleteDocument:document.uid];
        }
        
        NSAssert1(NO, @"Unhandled error executing commit: %@", [error localizedDescription]);
    }
}
-(void) archiveDocument:(DocumentManaged *) aDocument
{
    LNDataSource *inbox = [dataSources objectForKey: @"inbox"];
    LNDataSource *archive = [dataSources objectForKey: @"archive"];
    [inbox moveDocument: aDocument.uid destination: archive];
    [aDocument resetCachedDocument];
    aDocument.dataSourceId = archive.dataSourceId;
    aDocument.isEditable = [NSNumber numberWithBool: NO];
    [self commit];
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
        
        for (LNDataSource *ds in [dataSources allValues]) 
        {
            ds.login = login;
            ds.password = password;
        }

    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [dataSources release];
    [documentEntityDescription release];
    [documentUidPredicateTemplate release];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    NSAssert1(fetchResults != nil, @"Unhandled error executing document fetch: %@", [error localizedDescription]);
    
    if ([fetchResults count] > 0)
        return [fetchResults objectAtIndex:0];
    
    return nil;
}

-(PersonManaged *) findPersonByUid:(NSString *) anUid
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
        PersonManaged *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:managedObjectContext];
        person.uid = anUid;
        person.first = anUid;
        person.middle = anUid;
        person.last = anUid;
        NSLog(@"Created person: %@", anUid);
        return person;
    }
}

- (void)defaultsChanged:(NSNotification *)notif
{
        //purge cache - we need not it anymore
//    [lnDataSource purgeCache];
//    
//    [self createLNDatasourceFromDefaults];
}

-(void) createLNDatasourceFromDefaults
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSString *serverUrl = [currentDefaults objectForKey:@"serverUrl"];
    NSString *serverDatabaseViewInbox = [currentDefaults objectForKey:@"serverDatabaseViewInbox"];
    NSString *serverDatabaseViewArchive = [currentDefaults objectForKey:@"serverDatabaseViewArchive"];

    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
    
    NSString *login = [wrapper objectForKey:(NSString *)kSecAttrAccount];
    NSString *password = [wrapper objectForKey:(NSString *)kSecValueData];
    
    [wrapper release];
    
    [dataSources release];
    dataSources = [NSMutableDictionary dictionaryWithCapacity:2];
    [dataSources retain];
    
    LNDataSource *dsInbox = [[LNDataSource alloc] initWithId: @"inbox" viewId:serverDatabaseViewInbox andUrl:serverUrl];
    dsInbox.login = login;
    dsInbox.password = password;
    [dsInbox loadCache];
    dsInbox.delegate = self;

    [dataSources setObject:dsInbox forKey:@"inbox"];
    

    LNDataSource *dsArchive = [[LNDataSource alloc] initWithId: @"archive" viewId:serverDatabaseViewArchive andUrl:serverUrl];
    dsArchive.login = login;
    dsArchive.password = password;
    [dsArchive loadCache];
    dsArchive.delegate = self;
    
    [dataSources setObject:dsArchive forKey:@"archive"];
    
    if (!login || !password || [login isEqualToString:@""] || [password isEqualToString:@""])
        [self askLoginAndPassword:login];
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
- (void) updatePerformers:(NSArray *) uids resolution:(ResolutionManaged *) resolution
{
    [resolution removePerformers: resolution.performers]; //clean all performers
    
    for (NSString *uid in uids)
    {
        PersonManaged *performer = [self findPersonByUid: uid];
        if (performer)
        {
            [resolution addPerformersObject: performer];
            [performer addResolutionsObject: resolution];
        }
        else
            NSLog(@"Unknown person: %@", uid);
    }
}
- (void) updateAuthor:(NSString *) uid document:(DocumentManaged *) document
{
    document.author = [self findPersonByUid: uid];
    [document.author addDocumentsObject: document];
}
@end
