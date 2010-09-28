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
#import "LNDocumentReader.h"
#import "ResolutionManaged.h"
#import "SignatureManaged.h"
#import "Resolution.h"
#import "Signature.h"
#import "KeychainItemWrapper.h"
#import "PersonManaged.h"
#import "LNDocumentSaver.h"

#define kLoginFieldTag 1001
#define kPasswordFieldTag 1002

@interface DataSource(Private)
- (void) askLoginAndPassword:(NSString*) login;
- (NSArray *) unsyncedDocuments;
- (LNDocumentSaver *) documentSaver;
- (LNDocumentReader *) documentReader;
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
        
        [[NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext] retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(defaultsChanged:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
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
    NSArray *unsyncedDocuments = [self unsyncedDocuments];
    countDocumentsToSend = [unsyncedDocuments count];
    
    if (countDocumentsToSend)
    {
        __block DataSource *blockSelf = self;
        for (DocumentManaged *document in unsyncedDocuments)
        {
            [[self documentSaver] sendDocument:document.document handler:^(LNDocumentSaver *sender, NSString *error)
            {
                @synchronized(self)
                {
                    countDocumentsToSend--;
                }
                
                document.isSyncedValue = (error == nil);
                
                if (countDocumentsToSend <= 0)
                {
                    [self commit];
                    [[self documentReader] refreshDocuments];
                }
            }];
        }
    }
    else
    {
        [[self documentReader] refreshDocuments];
    }
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
- (DocumentManaged *) documentReader:(LNDocumentReader *) documentReader documentWithUid:(NSString *) anUid
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

- (ResolutionManaged *) documentReaderCreateResolution:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Resolution" inManagedObjectContext:managedObjectContext];
}

- (SignatureManaged *) documentReaderCreateSignature:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Signature" inManagedObjectContext:managedObjectContext];
}

- (DocumentManaged *) documentReaderCreateDocument:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Document" inManagedObjectContext:managedObjectContext];
}

- (AttachmentManaged *) documentReaderCreateAttachment:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Attachment" inManagedObjectContext:managedObjectContext];    
}

- (PageManaged *) documentReaderCreatePage:(LNDocumentReader *) documentReader
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:managedObjectContext];
}

- (NSArray *) documentReaderRootUids:(LNDocumentReader *) documentReader
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:self.documentEntityDescription];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject:@"uid"]];
    
    // Execute the fetch.
    NSError *error;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    NSAssert1(fetchResults != nil, @"Unhandled error executing document fetch: %@", [error localizedDescription]);
    return fetchResults;
}

- (void) documentReader:(LNDocumentReader *) documentReader removeObject:(NSManagedObject *) object;
{
    [managedObjectContext deleteObject:object];
}

- (void) documentReaderCommit:(LNDocumentReader *) documentReader
{
    [self commit];
}

- (PersonManaged *) documentReader:(LNDocumentReader *) documentReader personWithUid:(NSString *) anUid
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
        NSArray *chunks = [anUid componentsSeparatedByString: @" "];
        person.first = [anUid substringToIndex:1];
        person.middle = [anUid substringToIndex:1];
        person.last = [chunks objectAtIndex: 0];
        NSLog(@"Created person: %@", anUid);
        return person;
    }
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
    [documentUidPredicateTemplate release];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [documentSaver release];
    documentSaver = nil;
	[super dealloc];
}
@end

@implementation DataSource(Private)

- (void)defaultsChanged:(NSNotification *)notif
{
        //purge cache - we need not it anymore
//    [LNDocumentReader purgeCache];
//    
//    [self createLNDocumentReaderFromDefaults];
}

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
- (LNDocumentSaver *) documentSaver
{
    if (!documentSaver)
    {
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSString *serverUrl = [currentDefaults objectForKey:@"serverUrl"];
        documentSaver = [[LNDocumentSaver alloc] initWithUrl: serverUrl];
        
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
        
        documentSaver.login = [wrapper objectForKey:(NSString *)kSecAttrAccount];
        documentSaver.password = [wrapper objectForKey:(NSString *)kSecValueData];
        
        [wrapper release];

    }
    return documentSaver;
}

- (NSArray *) unsyncedDocuments
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext]];
	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isSynced==NO"]];
    
	NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    NSAssert1(fetchResults != nil, @"Unhandled error executing fetch folder content: %@", [error localizedDescription]);
    
    return fetchResults;    
}
@end
