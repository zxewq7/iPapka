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
#import "Attachment.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "ASINetworkQueue.h"
#import "LotusViewParser.h"
#import "LotusDocumentParser.h"

static NSString *field_Uid         = @"UNID";
static NSString *field_Title       = @"title";
static NSString *field_Date        = @"date";
static NSString *field_Author      = @"author";
static NSString *field_Modified    = @"modified";
static NSString *field_Form        = @"form";
static NSString *field_Text        = @"text";
static NSString *field_Performers  = @"performers";
static NSString *field_Attachments = @"attachments";
static NSString *field_AttachmentName = @"name";
static NSString *field_AttachmentPages = @"pages";

static NSString *form_Resolution   = @"Resolution";
static NSString *form_Signature    = @"Signature";
static NSString *url_FetchView     = @"%@/%@/%@?ReadViewEntries&count=100";
static NSString *url_FetchDocument = @"%@/%@/%@/%@?EditDocument";


@interface LNDataSource(Private)
- (void)fetchComplete:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)parseViewData:(NSString *) xmlFile;
- (void)fetchDocument:(Document *) document isNew:(BOOL) isNew;
- (void)parseDocumentData:(Document *) document xmlFile:(NSString *) xmlFile;
- (void)saveDocument:(Document *) document;
- (NSString *) documentDirectory:(NSString *) anUid;
- (void)fetchAttachment:(Attachment *) attachment document:(Document *)document pageUrls:(NSMutableDictionary *) pageUrls;
@end

@implementation LNDataSource
@synthesize viewReplicaId, databaseReplicaId, host, delegate;
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
    }
    return self;
}

#pragma mark -
#pragma mark Memory management
-(void)dealloc
{
    [_networkQueue reset];
	[_networkQueue release];
    [_databaseDirectory release];
	[cacheIndex release];
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Methods
-(void) refreshDocuments
{
    if ( [delegate respondsToSelector:@selector(documentsListWillRefreshed:)] ) 
        [delegate documentsListWillRefreshed:self];

    LNHttpRequest *request;
    NSString *url = [NSString stringWithFormat:url_FetchView, self.host, self.databaseReplicaId, self.viewReplicaId];
	request = [LNHttpRequest requestWithURL:[NSURL URLWithString:url]];
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

        if ( [blockSelf->delegate respondsToSelector:@selector(documentsListDidRefreshed:)] ) 
            [blockSelf->delegate documentsListDidRefreshed:self];
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
                document = [[Document alloc] init];
            else
            {
                NSLog(@"wrong form, document skipped: %@ %@", uid, form);
                continue;
            }
            document.title = [entry objectForKey:field_Title];
            document.uid = uid;
            document.author = [entry objectForKey:field_Author];
            document.dateModified = [entry objectForKey:field_Modified];
            document.date = [entry objectForKey:field_Date];
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
                document.title = [entry objectForKey:field_Title];
                document.author = [entry objectForKey:field_Author];
                document.dateModified = newDate;
                document.date = [entry objectForKey:field_Date];
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
    LNHttpRequest *request;
    NSString *url = [NSString stringWithFormat:url_FetchDocument, self.host, self.databaseReplicaId, self.viewReplicaId, document.uid];
	request = [LNHttpRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *directory = [self documentDirectory:document.uid];
    NSFileManager *df = [NSFileManager defaultManager];
    if (isNew)
        [df createDirectoryAtPath:directory withIntermediateDirectories:TRUE attributes:nil error:nil];

	[request setDownloadDestinationPath:[directory stringByAppendingPathComponent:@"index.html"]];
    request.requestHandler = ^(ASIHTTPRequest *request) {
        if ([request error] == nil  && [request responseStatusCode] == 200)
        {
            NSString *file = [request downloadDestinationPath];
            [self parseDocumentData:document xmlFile:file];
            [self saveDocument:document];
            [df removeItemAtPath:file error:NULL];
            if ( isNew && [delegate respondsToSelector:@selector(documentAdded:)] ) 
                [delegate documentAdded:document];
            else if ( !isNew && [delegate respondsToSelector:@selector(documentUpdated:)] )
                [delegate documentUpdated:document];
        }
        else
        {
            [df removeItemAtPath:directory error:NULL];
                //NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
        }
    };
	[_networkQueue addOperation:request];
}

- (void)fetchAttachment:(Attachment *) attachment document:(Document *)document pageUrls:(NSMutableDictionary *) pageUrls
{
    NSString *path = [[[self documentDirectory:document.uid] stringByAppendingPathComponent:@"attachments"] stringByAppendingPathComponent:attachment.title];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:TRUE 
                                               attributes:nil error:nil];
    attachment.path = path;
    for (NSString *pageName in [pageUrls allKeys]) 
    {
        NSString *url = [pageUrls objectForKey:pageName];
        [pageUrls setObject:@"" forKey:pageName];
        LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString:url]];
        [request setDownloadDestinationPath:[path stringByAppendingPathComponent:pageName]];
        request.requestHandler = ^(ASIHTTPRequest *request) {
            if ([request error] == nil  && [request responseStatusCode] == 200)
                [pageUrls setValue:[[request downloadDestinationPath] lastPathComponent] forKey:pageName];
            else
            {
                attachment.hasError = YES;
                [pageUrls setValue:@"error" forKey:pageName];
                    //NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
            }
            
            BOOL loaded = YES;
            for (NSString *fileName in [pageUrls allValues]) 
            {
                if ([fileName isEqualToString:@""]) 
                {
                    loaded = NO;
                    break;
                }
                if (loaded) 
                {
                    NSArray *pageNames = [[pageUrls allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                    NSMutableArray *pages = [NSMutableArray arrayWithCapacity:[pageNames count]];

                    for (NSString *pageName in pageNames) 
                        [pages addObject:[pageUrls objectForKey:pageName]];
                    attachment.pages = pages;
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
            if (loaded && [delegate respondsToSelector:@selector(documentUpdated:)]) 
                [delegate documentUpdated:document];
        };
        [_networkQueue addOperation:request];
        
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
- (void)parseDocumentData:(Document *) document xmlFile:(NSString *) xmlFile;
{
    LotusDocumentParser *parser = [LotusDocumentParser parseDocument:xmlFile];
    NSDictionary *parsedDocument = parser.documentEntry;
    if ([document isKindOfClass:[Resolution class]]) 
    {
       ((Resolution *)document).text = [parsedDocument objectForKey:field_Text];
        NSArray *performers = [parsedDocument objectForKey:field_Performers];
        if ([performers count])
            ((Resolution *)document).performers = [NSMutableDictionary dictionaryWithDictionary:[performers objectAtIndex:0]];
    }
    
    NSArray *attachments = [parsedDocument objectForKey:field_Attachments];
    NSMutableArray *documentAttachments = [NSMutableArray arrayWithCapacity:[attachments count]];
    for(NSDictionary *attachment in attachments)
    {
        Attachment *newAttachment = [[Attachment alloc] init];
        newAttachment.title = [attachment objectForKey:field_AttachmentName];
        NSArray *pages = [attachment objectForKey:field_AttachmentPages];
        NSMutableDictionary *pageUrls = [NSMutableDictionary dictionary];
        for (NSDictionary *page in pages) {
            for (NSString *pageName in page.allKeys) {
                NSString *pageUrl = [page objectForKey:pageName];
                [pageUrls setObject:pageUrl forKey:pageName];
            }
        }
        [self fetchAttachment:newAttachment document:document pageUrls:pageUrls];
        [documentAttachments addObject:newAttachment];
        [newAttachment release];
    }
    document.attachments = documentAttachments;
                            
    document.author = [parsedDocument objectForKey:field_Author];
    document.date = [parsedDocument objectForKey:field_Date];
    document.hasError = NO;
}
@end
