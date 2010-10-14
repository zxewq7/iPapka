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
#import "Comment.h"
#import "CommentAudio.h"
#import "SBJsonParser.h"
#import "AttachmentPagePainting.h"
#import "Attachment.h"
#import "AttachmentPage.h"

static NSString* OperationCount = @"OperationCount";

static NSString* kFieldVersion = @"version";
static NSString* kFieldParentId = @"parentid";
static NSString* kFieldUid = @"id";
static NSString* kFieldDeadline = @"deadline";
static NSString* kFieldPerformers = @"performers";
static NSString* kFieldText = @"text";
static NSString* kFieldType = @"type";
static NSString* kFieldFile = @"file";
static NSString* kPostFiledJson = @"json";

@interface LNDocumentWriter(Private)
- (void) syncDocument:(Document *) document;
- (void) syncFile:(FileField *) file;
- (NSString *)postDocumentUrl;
- (NSString *)postFileUrl;
- (NSString *)postFileField;
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
    
    allRequestsSent = NO;
    
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

    allRequestsSent = YES;
    
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
    
    [dictDocument setObject:document.uid forKey:kFieldUid];
    
    NSString *action;
    
    switch (document.statusValue)
    {
        case DocumentStatusNew:
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
            [dictDocument setObject:[parseFormatterSimple stringFromDate:resolution.deadline] forKey:kFieldDeadline];
        
        NSSet *performers = resolution.performers;
        NSUInteger performersCount = [performers count];
        if (performersCount)
        {
            NSMutableArray *performersArray = [[NSMutableArray alloc] initWithCapacity: performersCount];
            for(Person *performer in performers)
                [performersArray addObject:performer.uid];

            [dictDocument setObject:performersArray forKey:kFieldPerformers];
            
            [performersArray release];
        }
        
        if (resolution.text)
            [dictDocument setObject:resolution.text forKey:kFieldText];
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
    
    postData = [postData stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString: self.postDocumentUrl]];
    
    [request addRequestHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
    
    request.delegate = self;
    request.requestMethod = @"POST";
    //string already escaped
    [request appendPostData: [postData dataUsingEncoding: NSASCIIStringEncoding]];
    
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
    LNFormDataRequest *request = [LNFormDataRequest requestWithURL:[NSURL URLWithString: self.postFileUrl]];
    
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithCapacity:4];
    
    NSFileManager *df = [NSFileManager defaultManager];
    
    BOOL fileExists = [df isReadableFileAtPath:file.path];
    
    if ([file isKindOfClass: [CommentAudio class]])
    {
        CommentAudio *audio = (CommentAudio *) file;
        Comment *comment = audio.comment;
        
        [jsonDict setObject:comment.document.uid forKey:kFieldParentId];
        [jsonDict setObject:@"userComment" forKey:kFieldType];
        [jsonDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:(fileExists?@"application/audio":@"null"), @"content", nil] forKey:kFieldFile];
        
        if (audio.version)
            [jsonDict setObject:audio.version forKey:kFieldVersion];
        if (comment.text)
            [jsonDict setObject:comment.text forKey:kFieldText];
    }
    else if ([file isKindOfClass: [AttachmentPagePainting class]])
    {
        AttachmentPagePainting *painting = (AttachmentPagePainting *) file;
        
        [jsonDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:painting.page.attachment.document.uid, @"id",
                                                                       painting.page.attachment.uid, @"fileid",
                                                                       painting.page.number, @"pagenum", nil] forKey:@"parent"];
        [jsonDict setObject:@"drawing" forKey:kFieldType];
        [jsonDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:(fileExists?@"image/png":@"null"), @"content", nil] forKey:kFieldFile];
        
        if (painting.version)
            [jsonDict setObject:painting.version forKey:kFieldVersion];
        
    }
    else
        NSAssert1(NO, @"Unknown file to sync: %@", [file class]);

    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    
    NSError *error = nil;
    NSString *jsonString = [jsonWriter stringWithObject:jsonDict error: &error];
    
    [jsonWriter release];
    
    if (error)
    {
        NSString *err  = @"Unable to create json string";
        NSLog(@"%@", err);
        return;
    }

    [request setPostValue:jsonString forKey:kPostFiledJson];
    
    if (fileExists)
        [request setFile:file.path forKey:self.postFileField];
    
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
            
            NSString *uid = [parsedResponse valueForKey:kFieldUid];
            NSString *version = [parsedResponse valueForKey:kFieldVersion];
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
		BOOL x = !allRequestsSent || (queue.requestsCount != 0);
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

- (NSString *)postDocumentUrl
{
    if (!postDocumentUrl)
    {
        postDocumentUrl = [url stringByAppendingString:@"/ipad.transfer?OpenAgent&charset=utf-8"];
        [postDocumentUrl retain];
    }
    return postDocumentUrl;
}
- (NSString *)postFileUrl
{
    if (!postFileUrl)
    {
        postFileUrl = [url stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:@"serverUploadUrl"]];
        [postFileUrl retain];
    }
    return postFileUrl;
}

- (NSString *)postFileField
{
    if (!postFileField)
    {
        postFileField = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverUploadFileField"];
        [postFileField retain];
    }
    
    return postFileField;
}
@end
