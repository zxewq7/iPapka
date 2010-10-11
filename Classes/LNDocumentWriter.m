//
//  LNDocumentSaver.m
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 22.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDocumentWriter.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "Document.h"
#import "SBJsonWriter.h"
#import "DocumentResolution.h"
#import "DocumentSignature.h"
#import "DataSource.h"
#import "Person.h"
#import "PasswordManager.h"
#import "FileField.h"
#import "LNFormDataRequest.h"
#import "SignatureAudio.h"
#import "ResolutionAudio.h"
#import "SBJsonParser.h"

static NSString* OperationCount = @"OperationCount";

@interface LNDocumentWriter(Private)
- (void) syncDocument:(Document *) document;
- (void) syncFile:(FileField *) file;
@end

@implementation LNDocumentWriter
@synthesize unsyncedDocuments, unsyncedFiles, isSyncing;

- (id) initWithUrl:(NSString *) anUrl
{
    if ((self = [super init])) {
        parseFormatterSimple = [[NSDateFormatter alloc] init];
        //20100811
        [parseFormatterSimple setDateFormat:@"yyyyMMdd"];
        
        url = [anUrl retain];
        
        postDocumentUrl = [url stringByAppendingString:@"/ipad.transfer?OpenAgent&charset=utf-8"]; [postDocumentUrl retain];
        
        postFileUrl = [url stringByAppendingString:@"/e04f3dca071a7044c32577b50047f276?CreateDocument"]; [postFileUrl retain];
        
        postFileField = @"%%File.c325771a00553735.e04f3dca071a7044c32577b50047f276.$Body.0.2A6"; [postFileField retain];

        
        queue = [[ASINetworkQueue alloc] init];
        [queue setRequestDidFinishSelector:@selector(fetchComplete:)];
        [queue setRequestDidFailSelector:@selector(fetchFailed:)];

        [queue addObserver:self
                        forKeyPath:@"requestsCount"
                           options:0
                           context:&OperationCount];

        [queue setDelegate:self];
#warning only one request at time
        queue.maxConcurrentOperationCount = 1;
        [queue setShouldCancelAllRequestsOnFailure:NO];
        [queue go];
        
    }
    return self;
}


- (void) sync
{
    if (isSyncing) //prevent multiple syncs
        return;
    
    NSError *error = nil;
	if (![unsyncedDocuments performFetch:&error])
		NSAssert1(error == nil, @"Unhandled error executing unsynced documents: %@", [error localizedDescription]);

    [self willChangeValueForKey:@"isSyncing"];
    isSyncing = YES;
    [self didChangeValueForKey:@"isSyncing"];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[unsyncedDocuments sections] objectAtIndex:0];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    
    for (NSUInteger i = 0;i < numberOfObjects; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Document *document = [unsyncedDocuments objectAtIndexPath:indexPath];
        [self syncDocument:document];
    }

    if (![unsyncedFiles performFetch:&error])
		NSAssert1(error == nil, @"Unhandled error executing unsynced files: %@", [error localizedDescription]);

    sectionInfo = [[unsyncedFiles sections] objectAtIndex:0];
    numberOfObjects = [sectionInfo numberOfObjects];
    
    for (NSUInteger i = 0;i < numberOfObjects; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        FileField *file = [unsyncedFiles objectAtIndexPath:indexPath];
        [self syncFile:file];
    }

    if (!queue.requestsCount)// nothing running
    {
        [self willChangeValueForKey:@"isSyncing"];
        isSyncing = NO;
        [self didChangeValueForKey:@"isSyncing"];
    }
}

- (void)fetchComplete:(ASIHTTPRequest *)request
{
    void (^handler)(ASIHTTPRequest *request) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler(request);
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
    void (^handler)(ASIHTTPRequest *request) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler(request);
}

- (void)authenticationNeededForRequest:(ASIHTTPRequest *)request
{
    [[PasswordManager sharedPasswordManager] credentials:(request.authenticationRetryCount>0) handler:^(NSString *aLogin, NSString *aPassword, BOOL canceled){
        if (canceled) 
            [request cancelAuthentication];
        else
        {
            if ([request authenticationNeeded] == ASIHTTPAuthenticationNeeded) 
            {
                [request setUsername:aLogin];
                [request setPassword:aPassword];
                [request retryUsingSuppliedCredentials];
            } else if ([request authenticationNeeded] == ASIProxyAuthenticationNeeded) 
            {
                [request setProxyUsername:aLogin];
                [request setProxyPassword:aPassword];
                [request retryUsingSuppliedCredentials];
            }
        }
    }];
}

- (void)dealloc {
    [queue removeObserver:self forKeyPath:OperationCount];
    [queue reset];
	[queue release]; queue = nil;
    
    [parseFormatterSimple release]; parseFormatterSimple = nil;
    
    [postDocumentUrl release]; postDocumentUrl =  nil;
    
    [postFileUrl release]; postFileUrl = nil;
    
    [postFileField release]; postFileField = nil;
    
    [unsyncedDocuments release]; unsyncedDocuments = nil;
    [unsyncedFiles release]; unsyncedFiles = nil;
    
    
    [super dealloc];
}

#pragma mark -
#pragma mark Private
- (void) syncDocument:(Document *) document
{
    NSMutableDictionary *dictDocument = [NSMutableDictionary dictionaryWithCapacity: 6];
    
    [dictDocument setObject:document.uid forKey:@"id"];
    
    NSString *action;
    
    switch (document.statusValue)
    {
        case DocumentStatusDraft:
            action = @"save";
            break;
        case DocumentStatusAccepted:
            action = @"approve";
            break;
        case DocumentStatusDeclined:
            action = @"reject";
            break;
        default:
            NSLog(@"unknown status %d dor document %@", document.statusValue, document.uid);
            return;
    }
    
    [dictDocument setObject:action forKey:@"action"];
    
    if ([document isKindOfClass: [DocumentResolution class]])
    {
        DocumentResolution *resolution = (DocumentResolution *) document;
        
        if (resolution.deadline)
            [dictDocument setObject:[parseFormatterSimple stringFromDate:resolution.deadline] forKey:@"deadline"];
        
        NSSet *performers = resolution.performers;
        NSUInteger performersCount = [performers count];
        if (performersCount)
        {
            NSMutableArray *performersArray = [[NSMutableArray alloc] initWithCapacity: performersCount];
            for(Person *performer in performers)
                [performersArray addObject:performer.uid];

            [dictDocument setObject:performersArray forKey:@"performers"];
            
            [performersArray release];
        }
        
        if (resolution.text)
            [dictDocument setObject:resolution.text forKey:@"text"];
    }
    
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    
    NSError *error = nil;
    NSString *postData = [jsonWriter stringWithObject:dictDocument error: &error];
    
    [jsonWriter release];
    
    if (error)
    {
        NSString *err  = @"Unable to create json string";
        NSLog(@"%@", err);
        return;
    }
    
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString: postDocumentUrl]];
    
    [request addRequestHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
    
    request.delegate = self;
    request.requestMethod = @"POST";
    
    [request appendPostData: [postData dataUsingEncoding: NSUTF8StringEncoding]];
    
    __block LNDocumentWriter *blockSelf = self;
    
    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *error = [request error] == nil?
        ([request responseStatusCode] == 200?
         nil:
         NSLocalizedString(@"Bad response", "Bad response")):
        [[request error] localizedDescription];
        if (error)
            NSLog(@"error fetching url %@\n%@", [request originalURL], error);
        else
        {
            document.syncStatusValue = SyncStatusSynced;
            [[DataSource sharedDataSource] commit];
        }
        
    };
    
    [queue addOperation:request];    
}

- (void) syncFile:(FileField *) file
{
    LNFormDataRequest *request = [LNFormDataRequest requestWithURL:[NSURL URLWithString: postFileUrl]];
    
    if ([file isKindOfClass: [SignatureAudio class]])
    {
        SignatureAudio *audio = (SignatureAudio *) file;
        [request setPostValue:audio.parent.uid forKey:@"parentid"];
        if (audio.version)
            [request setPostValue:audio.version forKey:@"version"];
    }
    else if ([file isKindOfClass: [ResolutionAudio class]])
    {
        ResolutionAudio *audio = (ResolutionAudio *) file;
        [request setPostValue:audio.parent.uid forKey:@"parentid"];
        if (audio.version)
            [request setPostValue:audio.version forKey:@"version"];
    }

    [request setPostValue:@"" forKey:@"text"];

    [request setFile:file.path forKey:postFileField];
    
    request.delegate = self;
    
    
    __block LNDocumentWriter *blockSelf = self;
    
    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *error = [request error] == nil?
        ([request responseStatusCode] == 200?
         nil:
         NSLocalizedString(@"Bad response", "Bad response")):
        [[request error] localizedDescription];
        if (error)
            NSLog(@"error fetching url %@\n%@", [request originalURL], error);
        else
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSError *error = nil;
            NSString *jsonString = [request responseString];
            NSDictionary *parsedResponse = [json objectWithString:jsonString error:&error];
            [json release];
            if (parsedResponse == nil)
            {
                NSLog(@"error parsing response, error:%@ response: %@", error, jsonString);
                return;
            }
            
            NSString *uid = [parsedResponse valueForKey:@"id"];
            NSString *version = [parsedResponse valueForKey:@"version"];
            if (uid == nil || version == nil)
            {
                NSLog(@"error parsing response:", jsonString);
                return;
            }
            file.uid = uid;
            file.version = version;
            file.syncStatusValue = SyncStatusSynced;
            [[DataSource sharedDataSource] commit];
        }
        
    };
    
    [queue addOperation:request];    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &OperationCount)
    {
		BOOL x = (queue.requestsCount != 0);
        if ( x != isSyncing )
        {
            [self willChangeValueForKey:@"isSyncing"];
            isSyncing = x;
            [self didChangeValueForKey:@"isSyncing"];
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
