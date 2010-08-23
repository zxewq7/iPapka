//
//  LNDataSource.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDataSource.h"
#import "Document.h"
#import "Resolution.h"
#import "Signature.h"
#import "Attachment.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "ASINetworkQueue.h"
#import "LotusViewParser.h"
#import "SBJsonParser.h"

static NSString *field_Uid         = @"UNID";
static NSString *field_Title       = @"subject";
static NSString *field_Date        = @"date";
static NSString *field_Author      = @"author";
static NSString *field_Modified    = @"$modified";
static NSString *field_Subdocument = @"document";
static NSString *field_Deadline    = @"deadline";
static NSString *field_Form        = @"$Form";
static NSString *field_Text        = @"text";
static NSString *field_Performers  = @"performers";
static NSString *field_Attachments = @"files";
static NSString *field_AttachmentName = @"name";
static NSString *field_AttachmentUid = @"id";
static NSString *field_AttachmentPageCount = @"pageCount";

static NSString *form_Resolution   = @"resolution";
static NSString *form_Signature    = @"document";
static NSString *url_FetchView     = @"%@/%@/%@?ReadViewEntries&count=100";
static NSString *url_FetchDocument = @"%@/%@/%@/%@?OpenDocument";
    //document/id/file/file.id/page/pagenum
static NSString *url_AttachmentFetchPage = @"%@/%@/document/%@/file/%@/page/%d";
    //document/id/link/link.id/file/file.id/page/pagenum
static NSString *url_LinkAttachmentFetchPage = @"%@/document/%@/link/%@/file/%@/page/%d";

@interface LNDataSource(Private)
- (void)fetchComplete:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)parseViewData:(NSString *) xmlFile;
- (void)fetchDocument:(Document *) document isNew:(BOOL) isNew;
- (Document *)parseDocumentData:(Document *) document jsonFile:(NSString *) jsonFile;
- (void)saveDocument:(Document *) document;
- (NSString *) documentDirectory:(NSString *) anUid;
- (void)fetchAttachments:(Document *)document;
- (LNHttpRequest *) makeRequestWithUrl:(NSString *) url;
@end
static NSString* OperationCount = @"OperationCount";

@implementation LNDataSource
@synthesize viewReplicaId, databaseReplicaId, host, delegate, login, password;
-(id)init
{
    if ((self = [super init])) {
        _networkQueue = [[ASINetworkQueue alloc] init];
        [_networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
        [_networkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
        [_networkQueue setDelegate:self];
        [_networkQueue go];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _databaseDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        _databaseDirectory = [[_databaseDirectory stringByAppendingPathComponent:@"Cache"] stringByAppendingPathComponent:self.databaseReplicaId];
        [_databaseDirectory retain];

        [[NSFileManager defaultManager] createDirectoryAtPath:_databaseDirectory withIntermediateDirectories:TRUE 
                                                   attributes:nil error:nil]; 

        cacheIndex = [[NSMutableSet alloc] initWithCapacity:50];
        
        parseFormatterDst = [[NSDateFormatter alloc] init];
            //20100811T183249,89+04
        [parseFormatterDst setDateFormat:@"yyyyMMdd'T'HHmmss,S"];
        parseFormatterSimple = [[NSDateFormatter alloc] init];
            //20100811
        [parseFormatterSimple setDateFormat:@"yyyyMMdd"];
        
        [_networkQueue addObserver:self
                        forKeyPath:@"requestsCount"
                        options:0
                        context:&OperationCount];
        
        
    }
    return self;
}

#pragma mark -
#pragma mark Memory management
-(void)dealloc
{
    [_networkQueue removeObserver:self forKeyPath:OperationCount];
    [_networkQueue reset];
	[_networkQueue release];
    [_databaseDirectory release];
	[cacheIndex release];
    self.viewReplicaId = nil;
    self.databaseReplicaId = nil;
    self.host = nil;
    self.login = nil;
    self.password = nil;
    self.delegate = nil;
    [parseFormatterDst release];
    [parseFormatterSimple release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Methods
-(void) refreshDocuments
{
    if (isSyncing) //prevent spam syncing requests
        return;
    
    NSString *url = [NSString stringWithFormat:url_FetchView, self.host, self.databaseReplicaId, self.viewReplicaId];
    LNHttpRequest *request = [self makeRequestWithUrl: url];
	[request setDownloadDestinationPath:[_databaseDirectory stringByAppendingPathComponent:@"index.xml"]];
    __block LNDataSource *blockSelf = self;
    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *error = [request error] == nil?
                                ([request responseStatusCode] == 200?
                                    nil:
                                    NSLocalizedString(@"Bad response", "Bad response")):
                                [[request error] localizedDescription];
        if (error == nil)
            [blockSelf parseViewData:[request downloadDestinationPath]];
        else
            NSLog(@"error fetching url %@\n%@", [request originalURL], error);
    };
	[_networkQueue addOperation:request];
}

- (void)loadCache
{
    NSFileManager *df = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [df enumeratorAtPath:_databaseDirectory];
    
    NSString *file;
    while (file = [dirEnum nextObject]) 
    {
        NSString *documentObjectPath = [_databaseDirectory stringByAppendingPathComponent: [file stringByAppendingPathComponent:@"index.object"]];
        if ([df fileExistsAtPath:documentObjectPath isDirectory:NULL]) 
            [cacheIndex addObject:file];
    }
}

- (Document *) loadDocument:(NSString *) anUid
{
    NSString *path = [self documentDirectory:anUid];
    NSString *documentObjectPath = [path stringByAppendingPathComponent:@"index.object"];
    NSFileManager *df = [NSFileManager defaultManager];
    
    if ([df fileExistsAtPath:documentObjectPath isDirectory:NULL])
        return [NSKeyedUnarchiver unarchiveObjectWithFile:documentObjectPath];
    else
        return nil;
}

- (void)deleteDocument:(NSString *) anUid
{
    NSFileManager *df = [NSFileManager defaultManager];
    NSString *documentPath = [self documentDirectory:anUid];
    [df removeItemAtPath:documentPath error:NULL];
    [cacheIndex removeObject:anUid];
}

- (void)purgeCache
{
    NSFileManager *df = [NSFileManager defaultManager];
    [df removeItemAtPath:_databaseDirectory error:NULL];
}
@end

@implementation LNDataSource(Private)
#pragma mark -
#pragma mark ASINetworkQueue delegate
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

- (void)parseViewData:(NSString *) xmlFile
{
    LotusViewParser *parser = [LotusViewParser parseView:xmlFile];
    NSUInteger size = [parser.documentEntries count];
    NSMutableArray *newDocuments = [NSMutableArray arrayWithCapacity:size];
    NSMutableArray *updatedDocuments = [NSMutableArray arrayWithCapacity:size];
    NSMutableSet *allUids = [NSMutableSet setWithCapacity:size];
    NSMutableSet *uidsToRemove = [NSMutableSet setWithCapacity:size];
    for (NSDictionary *entry in parser.documentEntries) 
    {
        NSString *uid = [entry objectForKey:field_Uid];
            //new document
        if (![cacheIndex containsObject:uid])
        {
            Document *document = nil;
            NSString *form = [entry objectForKey:field_Form];
            if ([form isEqualToString:form_Resolution])
                document = [[Resolution alloc] init];
            else if ([form isEqualToString:form_Signature])
                document = [[Signature alloc] init];
            else
            {
                NSLog(@"wrong form, document skipped: %@ %@", uid, form);
                continue;
            }
            document.uid = uid;
            document.dateModified = [entry objectForKey:field_Modified];
            [newDocuments addObject:document];
            [document release];
        }
        else
        {
            NSDate *newDate = [entry objectForKey:field_Modified];
                //document updated
            Document *document = [self loadDocument:uid];
            if ([document.dateModified compare: newDate] == NSOrderedAscending)
            {
                document.dateModified = newDate;
                [updatedDocuments addObject:document];
            }
        }
        
        [allUids addObject:uid];
    }
    
        //remove obsoleted documents
    for (NSString *uid in cacheIndex)
    {
        if (![allUids containsObject:uid])
            [uidsToRemove addObject:uid];
    }
        //remove documents
    if ([uidsToRemove count])
    {
        
        NSMutableArray *documentToRemove = [NSMutableArray arrayWithCapacity:[uidsToRemove count]];
        
        for (NSString *uid in uidsToRemove)
        {
            Document *document = [self loadDocument:uid];
            [documentToRemove addObject:document];
            [self deleteDocument:uid];
        }
        
        if ( [delegate respondsToSelector:@selector(documentsDeleted:)] ) 
            [delegate documentsDeleted:documentToRemove];
    }
        //fetch new documents
    for (Document *document in newDocuments)
        [self fetchDocument: document isNew:YES];
    
        //fetch updated documents
    for (Document *document in updatedDocuments)
        [self fetchDocument: document isNew:NO];
}

- (void)fetchDocument:(Document *) document isNew:(BOOL) isNew
{
    NSString *url = [NSString stringWithFormat:url_FetchDocument, self.host, self.databaseReplicaId, self.viewReplicaId, document.uid];
    LNHttpRequest *request = [self makeRequestWithUrl: url];
    NSString *directory = [self documentDirectory:document.uid];
    NSFileManager *df = [NSFileManager defaultManager];
    if (isNew)
        [df createDirectoryAtPath:directory withIntermediateDirectories:TRUE attributes:nil error:nil];

	[request setDownloadDestinationPath:[directory stringByAppendingPathComponent:@"index.html"]];
    request.requestHandler = ^(ASIHTTPRequest *request) {
        if ([request error] == nil  && [request responseStatusCode] == 200)
        {
            NSString *file = [request downloadDestinationPath];
            Document *doc = [self parseDocumentData:document jsonFile:file];
            if (doc != nil) 
            {
                [self saveDocument:doc];
                    //[df removeItemAtPath:file error:NULL];
                if ( isNew && [delegate respondsToSelector:@selector(documentAdded:)] ) 
                    [delegate documentAdded:doc];
                else if ( !isNew && [delegate respondsToSelector:@selector(documentUpdated:)] )
                    [delegate documentUpdated:doc];
                [self fetchAttachments: document];
            }
        }
        else
        {
            [df removeItemAtPath:directory error:NULL];
                //NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
        }
    };
	[_networkQueue addOperation:request];
}

- (void)fetchAttachments:(Document *)document
{
    for (Attachment *attachment in document.attachments) 
    {
        NSString *path = [[[self documentDirectory:document.uid] stringByAppendingPathComponent:@"attachments"] stringByAppendingPathComponent:attachment.uid];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:TRUE 
                                                   attributes:nil error:nil];
        attachment.path = path;
        
        NSUInteger pageCount = [attachment.pages count];

        for (NSUInteger pageIndex = 0 ; pageIndex < pageCount; pageIndex++)
        {
            NSString *url = [NSString stringWithFormat:url_AttachmentFetchPage, host, databaseReplicaId, document.uid, attachment.uid, pageIndex];
            LNHttpRequest *request = [self makeRequestWithUrl: url];
            [request setDownloadDestinationPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", pageIndex]]];
            request.requestHandler = ^(ASIHTTPRequest *request) {
                if ([request error] == nil  && [request responseStatusCode] == 200)
                    [attachment.pages replaceObjectAtIndex:pageIndex withObject:[[request downloadDestinationPath] lastPathComponent]];
                else
                {
                    attachment.hasError = YES;
                    [attachment.pages replaceObjectAtIndex:pageIndex withObject:@"error"];
                        //NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
                }
                
                BOOL loaded = YES;
                for (NSString *fileName in attachment.pages) 
                {
                    if ([fileName isEqualToString:@""])
                    {
                        loaded = NO;
                        break;
                    }
                }
                attachment.isLoaded = loaded;
                if (loaded) 
                {
                    loaded = YES;
                    for (Attachment *attachment in document.attachments) 
                    {
                        if (!attachment.isLoaded) 
                        {
                            loaded = NO;
                            break;
                        }
                    }
                }
                document.isLoaded = loaded;
                [self saveDocument:document];
            };
            [_networkQueue addOperation:request];
            
        }        
    }
    
    

}

- (NSString *) documentDirectory:(NSString *) anUid
{
    NSString *directory = [_databaseDirectory stringByAppendingPathComponent: anUid];
    return directory;
}
- (void)saveDocument:(Document *) document
{
    NSString * path = [self documentDirectory:document.uid];
    
    [NSKeyedArchiver archiveRootObject: document toFile: [path stringByAppendingPathComponent:@"index.object"]];
    [cacheIndex addObject:document.uid];
        //    NSLog(@"saved to: %@", [path stringByAppendingPathComponent:@"index.object"]);
    
}
- (Document *)parseDocumentData:(Document *) document jsonFile:(NSString *) jsonFile
{
    NSString *jsonString = [NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:NULL];
    SBJsonParser *json = [[SBJsonParser new] autorelease];
    NSError *error = nil;
    NSDictionary *parsedDocument = [json objectWithString:jsonString error:&error];
    if (parsedDocument == nil) {
        NSLog(@"error parsing document %@, error:%@", document.uid, error);
        return nil;
    }
    NSDictionary *subDocument = [parsedDocument objectForKey:field_Subdocument];

    document.author = [parsedDocument objectForKey:field_Author];
    document.title = [subDocument objectForKey:field_Title];
    NSDate *dDate = nil;
    NSString *sDate = [parsedDocument objectForKey:field_Date];
    if (sDate && ![sDate isEqualToString:@""])
        dDate = [parseFormatterSimple dateFromString:sDate];
    document.date = dDate;
    
    if ([document isKindOfClass:[Resolution class]]) 
    {
        Resolution *resolution = (Resolution *)document;
        resolution.text = [parsedDocument objectForKey:field_Text];
        resolution.performers = [parsedDocument objectForKey:field_Performers];
        NSDate *dDeadline = nil;
        NSString *sDeadline = [parsedDocument objectForKey:field_Deadline];
        if (sDeadline && ![sDeadline isEqualToString:@""])
            dDeadline = [parseFormatterSimple dateFromString:sDeadline];
        resolution.deadline = dDeadline;
    }
    
    NSArray *attachments = [subDocument objectForKey:field_Attachments];
    NSMutableArray *documentAttachments = [NSMutableArray arrayWithCapacity:[attachments count]];
    for(NSDictionary *attachment in attachments)
    {
        Attachment *newAttachment = [[Attachment alloc] init];
        newAttachment.title = [attachment objectForKey:field_AttachmentName];
        newAttachment.uid = [attachment objectForKey:field_AttachmentUid];
        NSNumber *nPageCount = [attachment objectForKey:field_AttachmentPageCount];
        NSUInteger pageCount = nPageCount == nil?0:[nPageCount intValue];
        
        NSMutableArray *pages = [NSMutableArray arrayWithCapacity:pageCount];
        for (NSUInteger i = 0; i < pageCount ; i++) //just empty array
            [pages addObject:@""];

        newAttachment.pages = pages;
        [documentAttachments addObject:newAttachment];
        [newAttachment release];
    }
    document.attachments = documentAttachments;
    document.hasError = NO;
    return document;
}
- (LNHttpRequest *) makeRequestWithUrl:(NSString *) url
{
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString:url]];
    request.username = self.login;
    request.password = self.password;
    return request;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &OperationCount)
    {
		if(_networkQueue.requestsCount)
        {
            if ( !isSyncing && [delegate respondsToSelector:@selector(documentsListWillRefreshed:)] ) 
            {
                [delegate documentsListWillRefreshed:self];
                isSyncing = YES;
            }
        }
        else
        {
            isSyncing = NO;
            if ([ self.delegate respondsToSelector:@selector(documentsListDidRefreshed:)] ) 
                [self.delegate documentsListDidRefreshed:self];
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
