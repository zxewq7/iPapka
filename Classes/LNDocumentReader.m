//
//  LNDataSource.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDocumentReader.h"
#import "DocumentManaged.h"
#import "ResolutionManaged.h"
#import "SignatureManaged.h"
#import "AttachmentManaged.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "ASINetworkQueue.h"
#import "SBJsonParser.h"
#import "PageManaged.h"

static NSString *view_RootEntry = @"viewentry";
static NSString *view_EntryUid = @"@unid";
static NSString *view_EntryData = @"entrydata";
static NSString *view_EntryDataName = @"@name";
static NSString *view_EntryDataDate = @"datetime";
static NSString *view_EntryDataDateDst = @"@dst";
static NSString *view_EntryDataText = @"text";
static NSString *view_EntryDataFirstElement = @"0";

static NSString *field_Title       = @"subject";
static NSString *field_Author      = @"author";
static NSString *field_Modified    = @"$modified";
static NSString *field_Subdocument = @"document";
static NSString *field_Deadline    = @"deadline";
static NSString *field_Form        = @"$Form";
static NSString *field_Text        = @"text";
static NSString *field_Performers  = @"performers";
static NSString *field_ParentResolution  = @"parent";
static NSString *field_Attachments = @"files";
static NSString *field_AttachmentName = @"name";
static NSString *field_AttachmentUid = @"id";
static NSString *field_AttachmentPageCount = @"pageCount";
static NSString *field_Links = @"links";
static NSString *field_LinkUid = @"id";
static NSString *field_LinkTitle = @"info";

static NSString *form_Resolution   = @"resolution";
static NSString *form_Signature    = @"document";
static NSString *url_FetchViewFormat     = @"%@/%@?ReadViewEntries&OutputFormat=json";
static NSString *url_FetchDocumentFormat = @"%@/document/%@";
    //document/id/file/file.id/page/pagenum
static NSString *url_AttachmentFetchPageFormat = @"%@/document/%@/file/%@/page/%@";
    //document/id/link/link.id/file/file.id/page/pagenum
static NSString *url_LinkAttachmentFetchPageFormat = @"%@/document/%@/link/%@/file/%@/page/%@";

@interface LNDocumentReader(Private)
- (void)fetchComplete:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)parseViewData:(NSString *) jsonFile;
- (void)fetchDocument:(DocumentManaged *) document;
- (void)parseDocumentData:(DocumentManaged *) document parsedDocument:(NSDictionary *) parsedDocument;
- (NSString *) documentDirectory:(NSString *) anUid;
- (void)fetchPage:(PageManaged *)page;
- (void)checkDocumentIsLoaded:(DocumentManaged *)document;
- (LNHttpRequest *) makeRequestWithUrl:(NSString *) url;
- (NSDictionary *) extractValuesFromViewColumn:(NSArray *)entryData;
- (void) parseResolution:(ResolutionManaged *) resolution fromDictionary:(NSDictionary *) dictionary;
@end
static NSString* OperationCount = @"OperationCount";

@implementation LNDocumentReader
@synthesize login, password, isSyncing, dataSource;

- (id) initWithUrl:(NSString *) anUrl andViews:(NSArray *) vs
{
    if ((self = [super init])) {
        url = [anUrl retain];
        views = [vs retain];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _databaseDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        _databaseDirectory = [_databaseDirectory stringByAppendingPathComponent:@"Documents"];
        [_databaseDirectory retain];

        [[NSFileManager defaultManager] createDirectoryAtPath:_databaseDirectory withIntermediateDirectories:TRUE 
                                                   attributes:nil error:nil]; 

        parseFormatterDst = [[NSDateFormatter alloc] init];
            //20100811T183249,89+04
        [parseFormatterDst setDateFormat:@"yyyyMMdd'T'HHmmss,S"];
        parseFormatterSimple = [[NSDateFormatter alloc] init];
            //20100811
        [parseFormatterSimple setDateFormat:@"yyyyMMdd"];
        
        urlFetchView = [[NSString alloc] initWithFormat:url_FetchViewFormat, url, "%@"];
        urlFetchDocumentFormat = [[NSString alloc] initWithFormat:url_FetchDocumentFormat, url, @"%@"];
        urlAttachmentFetchPageFormat = [[NSString alloc] initWithFormat:url_AttachmentFetchPageFormat, url, @"%@", @"%@", @"%@"];
        urlLinkAttachmentFetchPageFormat = [[NSString alloc] initWithFormat:url_LinkAttachmentFetchPageFormat, url, @"%@", @"%@", @"%@", @"%@"];

        _networkQueue = [[ASINetworkQueue alloc] init];
        [_networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
        [_networkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
        [_networkQueue setDelegate:self];
        [_networkQueue go];
        
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
	self.dataSource = nil;
    [views release];
    [url release];
    self.login = nil;
    self.password = nil;
    [parseFormatterDst release];
    [parseFormatterSimple release];

    [urlFetchDocumentFormat release];
    [urlAttachmentFetchPageFormat release];
    [urlLinkAttachmentFetchPageFormat release];
    [urlFetchView release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Methods
-(void) refreshDocuments
{
    if (isSyncing) //prevent spam syncing requests
        return;
    
    LNHttpRequest *request = [self makeRequestWithUrl: urlFetchView];
	[request setDownloadDestinationPath:[_databaseDirectory stringByAppendingPathComponent:@"index.xml"]];
    __block LNDocumentReader *blockSelf = self;
    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *error = [request error] == nil?
                                ([request responseStatusCode] == 200?
                                    nil:
                                    NSLocalizedString(@"Bad response", "Bad response")):
                                [[request error] localizedDescription];
        if (error == nil)
            [blockSelf parseViewData:[request downloadDestinationPath]];
        else
        {
            NSLog(@"error fetching url %@\n%@", [request originalURL], error);
        }
    };
	[_networkQueue addOperation:request];
}

- (void)purgeCache
{
    NSFileManager *df = [NSFileManager defaultManager];
    [df removeItemAtPath:_databaseDirectory error:NULL];
}

@end

@implementation LNDocumentReader(Private)
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
    NSMutableDictionary *updatedDocuments = [NSMutableDictionary dictionaryWithCapacity:size];
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

        DocumentManaged *document = [[self dataSource] documentReader:self documentWithUid:uid];
        
        if (!document)
        {
            
            if ([form isEqualToString:form_Resolution])
                document = [[self dataSource] documentReaderCreateResolution:self];
            else if ([form isEqualToString:form_Signature])
                document = [[self dataSource] documentReaderCreateSignature:self];
            else
            {
                NSLog(@"wrong form, document skipped: %@ %@", uid, form);
                continue;
            }
            document.uid = uid;
            document.path = [self documentDirectory:uid];
            document.dateModified = dateModified;
        }
        else if ([document.dateModified compare: dateModified] == NSOrderedAscending)
        {
            document.dateModified = dateModified;
        }
        
        [updatedDocuments setObject:document forKey:uid];
    }
    
    NSArray *rootUids = [[self dataSource] documentReaderRootUids:self];
        //remove obsoleted documents
    for (NSString *uid in rootUids)
    {
        DocumentManaged *doc = [updatedDocuments objectForKey: uid];
        if (!doc)
        {
            DocumentManaged *obj = [[self dataSource] documentReader:self documentWithUid:uid];
            [[self dataSource] documentReader:self removeObject: obj];
        }
    }
        //fetch documents
    for (DocumentManaged *document in [updatedDocuments allValues])
        [self fetchDocument: document];
    
    [[self dataSource] documentReaderCommit: self];
}

- (void)fetchDocument:(DocumentManaged *) document
{
    NSString *anUrl = [NSString stringWithFormat:urlFetchDocumentFormat, document.uid];
    LNHttpRequest *request = [self makeRequestWithUrl: anUrl];

    NSFileManager *df = [NSFileManager defaultManager];
    
    [df createDirectoryAtPath:document.path withIntermediateDirectories:TRUE attributes:nil error:nil];

	[request setDownloadDestinationPath:[document.path stringByAppendingPathComponent:@"index.html"]];
    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *file = [request downloadDestinationPath];
        if ([request error] == nil  && [request responseStatusCode] == 200) //remove document if error
        {
            NSString *jsonString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL];
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSError *error = nil;
            NSDictionary *parsedDocument = [json objectWithString:jsonString error:&error];
            [json release];
            if (parsedDocument == nil) 
            {
                NSLog(@"error parsing document %@, error:%@", document.uid, error);
                [[self dataSource] documentReader:self removeObject: document];
            }
            else
                [self parseDocumentData:document parsedDocument:parsedDocument];
            
        }
        else
        {
            [[self dataSource] documentReader:self removeObject: document];
            NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
        }
        
        [df removeItemAtPath:file error:NULL];
        
        [[self dataSource] documentReaderCommit: self];
        
    };
	[_networkQueue addOperation:request];
}

- (NSString *) documentDirectory:(NSString *) anUid
{
    NSString *directory = [_databaseDirectory stringByAppendingPathComponent: anUid];
    return directory;
}

- (void)parseAttachments:(DocumentManaged *) document attachments:(NSArray *) attachments
{
    NSSet *existingAttachments = document.attachments;
    
    //remove obsoleted attachments
    for (AttachmentManaged *attachment in existingAttachments)
    {
        BOOL  exists = NO;
        for (NSDictionary *dictAttachment in attachments)
        {
            NSString *uid = [dictAttachment objectForKey:field_AttachmentUid];
            if ([attachment.uid isEqualToString :uid])
            {
                exists = YES;
                break;
            }
            
            if (!exists)
                [[self dataSource] documentReader:self removeObject: attachment];
        }
    }
    
    //add new attachments
    existingAttachments = document.attachments;
    
    for(NSDictionary *dictAttachment in attachments)
    {
        NSString *attachmentUid = [dictAttachment objectForKey:field_AttachmentUid];
        
        AttachmentManaged *attachment = nil;
        
        for (AttachmentManaged *a in existingAttachments)
        {
            if ([a.uid isEqualToString: attachmentUid])
            {
                attachment = a;
                break;
            }
        }
        
        if (!attachment) //create new attachment
        {
            attachment = [[self dataSource] documentReaderCreateAttachment:self];
            attachment.title = [dictAttachment objectForKey:field_AttachmentName];
            attachment.uid = [dictAttachment objectForKey:field_AttachmentUid];
            attachment.isFetchedValue = NO;
            attachment.document = document;
            
            NSUInteger pageCount = [[dictAttachment objectForKey:field_AttachmentPageCount] intValue];
            
            for (NSUInteger i = 0; i < pageCount ; i++) //create page stubs
            {
                PageManaged *page = [[self dataSource] documentReaderCreatePage:self];
                page.numberValue = i;
                page.isFetchedValue = NO;
                page.attachment = attachment;
                [attachment addPagesObject: page];
            }
            [document addAttachmentsObject: attachment];
        }
    }
    
    //fetch attachment pages
    existingAttachments = document.attachments;
    for (AttachmentManaged *attachment in existingAttachments)
    {
        if (attachment.isFetchedValue)
            continue;
        
        for (PageManaged *page in attachment.pages)
        {
            if (page.isFetchedValue)
                continue;
            
            [self fetchPage: page];
        }
    }
    
}

- (void)parseDocumentData:(DocumentManaged *) document parsedDocument:(NSDictionary *) parsedDocument
{
    NSDictionary *subDocument = [parsedDocument objectForKey:field_Subdocument];
    
    document.author = [parsedDocument objectForKey:field_Author];
    document.title = [subDocument objectForKey:field_Title];
    
    if ([document isKindOfClass:[ResolutionManaged class]]) 
    {
        ResolutionManaged *resolution = (ResolutionManaged *)document;
        [self parseResolution:resolution fromDictionary:parsedDocument];
    }
    
    //parse attachments
    NSArray *attachments = [subDocument objectForKey:field_Attachments];

    [self parseAttachments:document attachments: attachments];
    
    
    //parse links
    NSArray *links = [subDocument objectForKey:field_Links];
    
    NSSet *existingLinks = document.links;

    //remove obsoleted attachments
    for (DocumentManaged *link in existingLinks)
    {
        BOOL  exists = NO;
        for (NSDictionary *dictLink in links)
        {
            NSString *uid = [dictLink objectForKey:field_LinkUid];
            if ([link.uid isEqualToString :uid])
            {
                exists = YES;
                break;
            }
            
            if (!exists)
                [[self dataSource] documentReader:self removeObject: link];
        }
    }
    
    //add new links
    existingLinks = document.links;
    
    for(NSDictionary *dictLink in links)
    {
        NSString *uid = [dictLink objectForKey:field_LinkUid];
        
        DocumentManaged *link = nil;
        
        for (DocumentManaged *l in existingLinks)
        {
            if ([l.uid isEqualToString: uid])
            {
                link = l;
                break;
            }
        }
        
        if (!link) //create new link
        {
            link = [[self dataSource] documentReaderCreateDocument:self];
            link.uid = [dictLink objectForKey:field_LinkUid];
            link.title = [dictLink objectForKey:field_LinkTitle];
            link.isFetchedValue = NO;
            
            link.parent = document;
            
            NSArray *linkAttachments = [dictLink objectForKey:field_Attachments];
            
            [self parseAttachments:link attachments: linkAttachments];
            
            [document addLinksObject: link];
        }
    }
}

- (LNHttpRequest *) makeRequestWithUrl:(NSString *) anUrl
{
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString: anUrl]];
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
		BOOL x = (_networkQueue.requestsCount == 0);
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
- (void)fetchPage:(PageManaged *)page
{
    NSFileManager *df = [NSFileManager defaultManager];
    
    NSString *path = page.path;
    
    [df createDirectoryAtPath:path withIntermediateDirectories:TRUE 
                   attributes:nil error:nil];

    NSString *urlPattern;
    
    AttachmentManaged *attachment = page.attachment;
    DocumentManaged *rootDocument = attachment.document;

#warning recursive links???
    if (rootDocument.parent) //link
    {
        rootDocument = rootDocument.parent;
        DocumentManaged *link = rootDocument;
        
        urlPattern = [NSString stringWithFormat:urlLinkAttachmentFetchPageFormat, rootDocument.uid, link.uid, @"%@", @"%d"];
    }
    else
        urlPattern = [NSString stringWithFormat:urlAttachmentFetchPageFormat, rootDocument.uid, @"%@", @"%d"];
    
    NSString *anUrl = [NSString stringWithFormat:urlPattern, attachment.uid, [page.number intValue]];
    

    LNHttpRequest *request = [self makeRequestWithUrl: anUrl];
    
    [request setDownloadDestinationPath:[path stringByAppendingPathComponent:path]];
    request.requestHandler = ^(ASIHTTPRequest *request) 
    {
        if ([request error] == nil  && [request responseStatusCode] == 200)
        {
            page.isFetchedValue = YES;
        }
        else
        {
            page.isFetchedValue = NO;
            //remove bugged response
            [df removeItemAtPath:[request downloadDestinationPath] error:NULL];
            NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
        }
        [self checkDocumentIsLoaded:rootDocument];
    };

    [_networkQueue addOperation:request];
}
- (void)checkDocumentIsLoaded:(DocumentManaged *)document
{
    BOOL pagesFetched = YES;

    for (AttachmentManaged *attachment in document.attachments)
    {
        if (attachment.isFetchedValue)
            continue;
        
        for (PageManaged *page in attachment.pages) 
        {
            if (!page.isFetchedValue)
            {
                pagesFetched = NO;
                break;
            }
        }
        
        if (pagesFetched)
            attachment.isFetchedValue = YES;
    }

    if (!pagesFetched)
        return;
    
    BOOL linksFetched = YES;
    
    for (DocumentManaged *link in document.links) 
    {
        
        if (link.isFetched)
            continue;
        
        linksFetched = NO;
        break;
    }

    if (linksFetched)
        document.isFetchedValue = YES;
    
}
- (void) parseResolution:(ResolutionManaged *) resolution fromDictionary:(NSDictionary *) dictionary;
{
    resolution.text = [dictionary objectForKey:field_Text];
    resolution.author = [dictionary objectForKey:field_Author];
    resolution.performers = [dictionary objectForKey:field_Performers];
    NSDate *dDeadline = nil;
    NSString *sDeadline = [dictionary objectForKey:field_Deadline];
    if (sDeadline && ![sDeadline isEqualToString:@""])
        dDeadline = [parseFormatterSimple dateFromString:sDeadline];

    resolution.deadline = dDeadline;

    NSDictionary *parsedParentResolution = [dictionary objectForKey:field_ParentResolution];
    if (parsedParentResolution) 
    {
        ResolutionManaged *parentResolution = [[self dataSource] documentReaderCreateResolution:self];
        [self parseResolution:parentResolution fromDictionary:parsedParentResolution];
        parentResolution.title = resolution.title;
        resolution.parentResolution = parentResolution;
    }
}
@end
