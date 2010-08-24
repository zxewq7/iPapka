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
#import "SBJsonParser.h"

static NSString *view_RootEntry = @"viewentry";
static NSString *view_EntryUid = @"@unid";
static NSString *view_EntryData = @"entrydata";
static NSString *view_EntryDataName = @"@name";
static NSString *view_EntryDataDate = @"datetime";
static NSString *view_EntryDataDateDst = @"@dst";
static NSString *view_EntryDataText = @"text";
static NSString *view_EntryDataFirstElement = @"0";

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
static NSString *url_FetchView     = @"%@/%@/%@/";
static NSString *url_FetchDocument = @"%@/%@/document/%@";
    //document/id/file/file.id/page/pagenum
static NSString *url_AttachmentFetchPage = @"%@/%@/document/%@/file/%@/page/%@";
    //document/id/link/link.id/file/file.id/page/pagenum
static NSString *url_LinkAttachmentFetchPage = @"%@/document/%@/link/%@/file/%@/page/%@";

@interface LNDataSource(Private)
- (void)fetchComplete:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)parseViewData:(NSString *) jsonFile;
- (void)fetchDocument:(Document *) document isNew:(BOOL) isNew;
- (Document *)parseDocumentData:(Document *) document jsonFile:(NSString *) jsonFile;
- (void)saveDocument:(Document *) document;
- (NSString *) documentDirectory:(NSString *) anUid;
- (void)fetchAttachments:(Document *)document;
- (void)fetchAttachments:(Document *)document rootDocument:(Document *)aRootDocument urlPattern:(NSString *) anUrlPattern basePath:(NSString *) aBasePath;
- (void)checkDocumentIsLoaded:(Document *)document;
- (LNHttpRequest *) makeRequestWithUrl:(NSString *) url;
- (NSDictionary *) extractValuesFromViewColumn:(NSArray *)entryData;
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

- (void)parseViewData:(NSString *) jsonFile
{
    NSString *jsonString = [NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:NULL];
    SBJsonParser *json = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *parsedView = [json objectWithString:jsonString error:&error];
    [json release];
    if (parsedView == nil) {
        NSLog(@"error parsing view, error:%@", error);
        return;
    }
    NSArray *entries = [parsedView objectForKey:view_RootEntry]; 
    NSUInteger size = [entries count];
    NSMutableArray *newDocuments = [NSMutableArray arrayWithCapacity:size];
    NSMutableArray *updatedDocuments = [NSMutableArray arrayWithCapacity:size];
    NSMutableSet *allUids = [NSMutableSet setWithCapacity:size];
    NSMutableSet *uidsToRemove = [NSMutableSet setWithCapacity:size];
    for (NSDictionary *entry in entries) 
    {
        NSString *uid = [entry objectForKey:view_EntryUid];
            //new document
        NSArray *entryData = [entry objectForKey:view_EntryData];
        NSDictionary *values = [self extractValuesFromViewColumn: entryData];
        NSString *form = [values objectForKey:field_Form];
        NSDate *dateModified = [values objectForKey:field_Modified];
        NSAssert(form != nil, @"Unable to find form in view");
        NSAssert(dateModified != nil, @"Unable to find dateModified in view");

        if (![cacheIndex containsObject:uid])
        {
            
            Document *document = nil;

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
            document.dateModified = dateModified;
            [newDocuments addObject:document];
            [document release];
        }
        else
        {
                //document updated
            Document *document = [self loadDocument:uid];
            if ([document.dateModified compare: dateModified] == NSOrderedAscending)
            {
                document.dateModified = dateModified;
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
    NSString *url = [NSString stringWithFormat:url_FetchDocument, self.host, self.databaseReplicaId, document.uid];
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
            NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
        }
    };
	[_networkQueue addOperation:request];
}

- (void)fetchAttachments:(Document *)document
{
    NSString *path = [[self documentDirectory:document.uid] stringByAppendingPathComponent:@"attachments"];

    NSString *urlPattern = [NSString stringWithFormat:url_AttachmentFetchPage, host, databaseReplicaId, document.uid, @"%@", @"%d"];
    
    [self fetchAttachments:document rootDocument:document urlPattern:urlPattern basePath:path];
}

- (NSString *) documentDirectory:(NSString *) anUid
{
    NSString *directory = [_databaseDirectory stringByAppendingPathComponent: anUid];
    return directory;
}
- (void)saveDocument:(Document *) document
{
    @synchronized(self) 
    {
        NSString * path = [self documentDirectory:document.uid];
        
        [NSKeyedArchiver archiveRootObject: document toFile: [path stringByAppendingPathComponent:@"index.object"]];
        [cacheIndex addObject:document.uid];
            //    NSLog(@"saved to: %@", [path stringByAppendingPathComponent:@"index.object"]);
    }
}
- (Document *)parseDocumentData:(Document *) document jsonFile:(NSString *) jsonFile
{
    NSString *jsonString = [NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:NULL];
    SBJsonParser *json = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *parsedDocument = [json objectWithString:jsonString error:&error];
    [json release];
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
- (NSDictionary *) extractValuesFromViewColumn:(NSArray *)entryData
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSDictionary *entryColumn in entryData)
    {
        NSString *colName = [entryColumn objectForKey:view_EntryDataName];
        NSDictionary *text = [entryColumn objectForKey:view_EntryDataText];
        if (text != nil) 
        {
            NSDictionary *value = [entryColumn objectForKey:view_EntryDataText];
            [result setObject:[value objectForKey:view_EntryDataFirstElement] forKey:colName];
            continue;
        }
        
        NSDictionary *date = [entryColumn objectForKey:view_EntryDataDate];
        
        if (date != nil)
        {
            NSDictionary *value = [entryColumn objectForKey:view_EntryDataDate];
            NSString *sDst = [value objectForKey:view_EntryDataDateDst];
            NSString *sValue = [value objectForKey:view_EntryDataFirstElement];
            NSDate *dValue = nil;
            if (sDst && [sDst isEqualToString:@"true"]) 
                dValue = [parseFormatterDst dateFromString:sValue];
            else
                dValue = [parseFormatterSimple dateFromString:sValue];
            if (dValue != nil)
                [result setObject:dValue forKey:colName];
            continue;
        }
    }
    
    return result;
}
- (void)fetchAttachments:(Document *)document rootDocument:(Document *)aRootDocument urlPattern:(NSString *) anUrlPattern basePath:(NSString *) aBasePath
{
    for (Attachment *attachment in document.attachments) 
    {
        NSString *path = [aBasePath stringByAppendingPathComponent: attachment.uid];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:TRUE 
                                                   attributes:nil error:nil];
        attachment.path = path;
        NSUInteger pageCount = [attachment.pages count];
        
        for (NSUInteger pageIndex = 0 ; pageIndex < pageCount; pageIndex++)
        {
            NSString *url = [NSString stringWithFormat:anUrlPattern, attachment.uid, pageIndex];
            LNHttpRequest *request = [self makeRequestWithUrl: url];
            
            [request setDownloadDestinationPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", pageIndex]]];
            request.requestHandler = ^(ASIHTTPRequest *request) {
                if ([request error] == nil  && [request responseStatusCode] == 200)
                    [attachment.pages replaceObjectAtIndex:pageIndex withObject:[[request downloadDestinationPath] lastPathComponent]];
                else
                {
                    attachment.hasError = YES;
                    [attachment.pages replaceObjectAtIndex:pageIndex withObject:@"error"];
                    NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
                }
                [self checkDocumentIsLoaded:aRootDocument];
            };
            [_networkQueue addOperation:request];
        }        
    }
}
- (void)checkDocumentIsLoaded:(Document *)document
{
    BOOL attachmentsLoaded = YES;

    for (Attachment *attachment in document.attachments)
    {
        if (attachment.isLoaded)
            continue;
        
        for (NSString *fileName in attachment.pages) 
        {
            if ([fileName isEqualToString:@""])
            {
                attachmentsLoaded = NO;
                break;
            }
        }
        attachment.isLoaded = attachmentsLoaded;
    }
    
    BOOL documentLoaded = YES;
    if (attachmentsLoaded) 
    {
        for (Attachment *attachment in document.attachments) 
        {
            if (!attachment.isLoaded) 
            {
                documentLoaded = NO;
                break;
            }
        }
    }
    document.isLoaded = documentLoaded;
    [self saveDocument:document];
    
}
@end
