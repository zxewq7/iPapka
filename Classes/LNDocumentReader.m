//
//  LNDataSource.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDocumentReader.h"
#import "Document.h"
#import "DocumentResolution.h"
#import "DocumentSignature.h"
#import "Attachment.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "ASINetworkQueue.h"
#import "SBJsonParser.h"
#import "AttachmentPage.h"
#import "Person.h"

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
static NSString *field_Form        = @"type";
static NSString *field_Uid         = @"id";
static NSString *field_Text        = @"text";
static NSString *field_Performers  = @"performers";
static NSString *field_ParentResolution  = @"parent";
static NSString *field_Attachments = @"files";
static NSString *field_AttachmentName = @"name";
static NSString *field_AttachmentPageCount = @"pageCount";
static NSString *field_Links = @"links";
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
- (void)parseViewData:(NSString *) jsonString;
- (void)fetchDocuments;
- (void)parseDocumentData:(NSDictionary *) parsedDocument;
- (NSString *) documentDirectory:(NSString *) anUid;
- (void)fetchPage:(AttachmentPage *)page;
- (LNHttpRequest *) makeRequestWithUrl:(NSString *) url;
- (NSDictionary *) extractValuesFromViewColumn:(NSArray *)entryData;
- (void) parseResolution:(DocumentResolution *) resolution fromDictionary:(NSDictionary *) dictionary;
@end
static NSString* OperationCount = @"OperationCount";

@implementation LNDocumentReader
@synthesize login, password, isSyncing, dataSource;

- (id) initWithUrl:(NSString *) anUrl andViews:(NSArray *) views
{
    if ((self = [super init])) {
        
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
        
        NSMutableArray *vs = [[NSMutableArray alloc] initWithCapacity: [views count]];
        for (NSString *vn in views)
            [vs addObject: [NSString stringWithFormat:url_FetchViewFormat, anUrl, vn]];
        
        viewUrls = vs;
        
        urlFetchDocumentFormat = [[NSString alloc] initWithFormat:url_FetchDocumentFormat, anUrl, @"%@"];
        urlAttachmentFetchPageFormat = [[NSString alloc] initWithFormat:url_AttachmentFetchPageFormat, anUrl, @"%@", @"%@", @"%@"];
        urlLinkAttachmentFetchPageFormat = [[NSString alloc] initWithFormat:url_LinkAttachmentFetchPageFormat, anUrl, @"%@", @"%@", @"%@", @"%@"];

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
    [viewUrls release];
    self.login = nil;
    self.password = nil;
    [parseFormatterDst release];
    [parseFormatterSimple release];

    [urlFetchDocumentFormat release];
    [urlAttachmentFetchPageFormat release];
    [urlLinkAttachmentFetchPageFormat release];
    [uidsToFetch release]; uidsToFetch = nil;
    [fetchedUids release]; fetchedUids = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Methods
-(void) refreshDocuments
{
    if (isSyncing) //prevent spam syncing requests
        return;

    [uidsToFetch release];
    
    [fetchedUids release];
    
    uidsToFetch = [[NSMutableSet alloc] init];
    
    fetchedUids = [[NSMutableSet alloc] init];
    
    viewsLeftToFetch = [viewUrls count];
    
    for (NSString *url in viewUrls)
    {
        LNHttpRequest *request = [self makeRequestWithUrl: url];
        
        __block LNDocumentReader *blockSelf = self;
        
        request.requestHandler = ^(ASIHTTPRequest *request) {
            NSString *error = [request error] == nil?
            ([request responseStatusCode] == 200?
             nil:
             NSLocalizedString(@"Bad response", "Bad response")):
            [[request error] localizedDescription];
            if (error == nil)
                [blockSelf parseViewData:[request responseString]];
            else
            {
                NSLog(@"error fetching url %@\n%@", [request originalURL], error);
            }
            
            @synchronized (blockSelf)
            {
                viewsLeftToFetch--;
            }
            
            if (viewsLeftToFetch == 0) //all view fetched
            {
                NSSet *rootUids = [[blockSelf dataSource] documentReaderRootUids:blockSelf];
                //remove obsoleted documents
                for (NSString *uid in rootUids)
                {
                    if (![blockSelf->fetchedUids containsObject: uid])
                    {
                        Document *obj = [[blockSelf dataSource] documentReader:blockSelf documentWithUid:uid];
                        if (obj)
                            [[blockSelf dataSource] documentReader:blockSelf removeObject: obj];
                    }
                }
                [blockSelf fetchDocuments];
            }

        };
        [_networkQueue addOperation:request];        
    }
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

- (void)parseViewData:(NSString *) jsonString
{
    SBJsonParser *json = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *parsedView = [json objectWithString:jsonString error:&error];
    [json release];
    if (parsedView == nil) {
        NSLog(@"error parsing view, error:%@", error);
        return;
    }
    NSArray *entries = [parsedView objectForKey:view_RootEntry]; 
    for (NSDictionary *entry in entries) 
    {
        NSString *uid = [entry objectForKey:view_EntryUid];
            //new document
        NSArray *entryData = [entry objectForKey:view_EntryData];
        
        NSDictionary *values = [self extractValuesFromViewColumn: entryData];
        
        NSDate *dateModified = [values objectForKey:field_Modified];
        
        NSAssert(dateModified != nil, @"Unable to find dateModified in view");

        Document *document = [[self dataSource] documentReader:self documentWithUid:uid];
        
        if (!document)
            [uidsToFetch addObject: uid];
        else if ([document.dateModified compare: dateModified] == NSOrderedAscending)
            [uidsToFetch addObject: uid];
        
        [fetchedUids addObject: uid];
    }
}

- (void)fetchDocuments
{
    __block LNDocumentReader *blockSelf = self;
    
    documentsLeftToFetch = [uidsToFetch count];
    
    for (NSString *uid in uidsToFetch)
    {
        NSString *anUrl = [NSString stringWithFormat:urlFetchDocumentFormat, uid];
        LNHttpRequest *request = [blockSelf makeRequestWithUrl: anUrl];
        
        request.requestHandler = ^(ASIHTTPRequest *request) {
            if ([request error] == nil  && [request responseStatusCode] == 200) //remove document if error
            {
                NSString *jsonString = [request responseString];
                SBJsonParser *json = [[SBJsonParser alloc] init];
                NSError *error = nil;
                NSDictionary *parsedDocument = [json objectWithString:jsonString error:&error];
                [json release];
                if (parsedDocument == nil) 
                    NSLog(@"error parsing document %@, error:%@", uid, error);
                else
                    [blockSelf parseDocumentData:parsedDocument];
            }
            else
            {
                NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
            }
            
            @synchronized (blockSelf)
            {
                documentsLeftToFetch--;
            }
            
            if (documentsLeftToFetch == 0) //fetch all resources
            {
                NSArray *unfetchedResources = [blockSelf->dataSource documentReaderUnfetchedResources:blockSelf];
                for(NSObject *resource in unfetchedResources)
                {
                    if ([resource isKindOfClass: [AttachmentPage class]])
                        [blockSelf fetchPage:(AttachmentPage *) resource];
                    else
                        NSAssert1(NO, @"invalid resource: ", [resource class]);
                }
            }
        };
        [_networkQueue addOperation:request];
    }
}

- (NSString *) documentDirectory:(NSString *) anUid
{
    NSString *directory = [_databaseDirectory stringByAppendingPathComponent: anUid];
    return directory;
}

- (void)parseAttachments:(Document *) document attachments:(NSArray *) attachments
{
    NSSet *existingAttachments = document.attachments;
    
    //remove obsoleted attachments
    for (Attachment *attachment in existingAttachments)
    {
        BOOL  exists = NO;
        for (NSDictionary *dictAttachment in attachments)
        {
            NSString *uid = [dictAttachment objectForKey:field_Uid];
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
        NSString *attachmentUid = [dictAttachment objectForKey:field_Uid];
        
        Attachment *attachment = nil;
        
        for (Attachment *a in existingAttachments)
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
            attachment.uid = [dictAttachment objectForKey:field_Uid];
            attachment.document = document;
            
            NSUInteger pageCount = [[dictAttachment objectForKey:field_AttachmentPageCount] intValue];
            
            for (NSUInteger i = 0; i < pageCount ; i++) //create page stubs
            {
                AttachmentPage *page = [[self dataSource] documentReaderCreatePage:self];
                page.numberValue = i;
                page.isFetchedValue = NO;
                page.attachment = attachment;
                [attachment addPagesObject: page];
            }
            [document addAttachmentsObject: attachment];
        }
    }
}

- (void)parseDocumentData:(NSDictionary *) parsedDocument
{
    @synchronized (self)
    {
        NSString *form = [parsedDocument objectForKey:field_Form];
        NSString *uid = [parsedDocument objectForKey:field_Uid];
        
        NSDictionary *subDocument = [parsedDocument objectForKey:field_Subdocument];
        
        Person *author = [[self dataSource] documentReader:self personWithUid: [parsedDocument objectForKey:field_Author]];
        
        if (!author)
        {
            NSLog(@"no author, document skipped: %@", uid);
            return;
        }
        
        Document *document;
        
        if ([form isEqualToString:form_Resolution])
            document = [[self dataSource] documentReaderCreateResolution:self];
        else if ([form isEqualToString:form_Signature])
            document = [[self dataSource] documentReaderCreateSignature:self];
        else
        {
            NSLog(@"wrong form, document skipped: %@ %@", uid, form);
            return;
        }
        
        [author addDocumentsObject: document];
        
        document.author = author;
        
        document.uid = uid;
        
        document.title = [subDocument objectForKey:field_Title];
        
        document.path = [self documentDirectory: uid];
        
#warning wrong dateModified
        document.dateModified = [NSDate date];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;

        NSDateComponents *comps = [calendar components:unitFlags fromDate:document.dateModified];

        document.strippedDateModified = [calendar dateFromComponents:comps];
        
        if ([document isKindOfClass:[DocumentResolution class]]) 
        {
            DocumentResolution *resolution = (DocumentResolution *)document;
            [self parseResolution:resolution fromDictionary:parsedDocument];
        }
        
        //parse attachments
        NSArray *attachments = [subDocument objectForKey:field_Attachments];
        
        [self parseAttachments:document attachments: attachments];
        
        //parse links
        NSArray *links = [subDocument objectForKey:field_Links];
        
        NSSet *existingLinks = document.links;
        
        //remove obsoleted attachments
        for (Document *link in existingLinks)
        {
            BOOL  exists = NO;
            for (NSDictionary *dictLink in links)
            {
                NSString *linkUid = [dictLink objectForKey:field_Uid];
                if ([link.uid isEqualToString :linkUid])
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
            NSString *linkUid = [dictLink objectForKey:field_Uid];
            
            Document *link = nil;
            
            for (Document *l in existingLinks)
            {
                if ([l.uid isEqualToString: linkUid])
                {
                    link = l;
                    break;
                }
            }
            
            if (!link) //create new link
            {
                link = [[self dataSource] documentReaderCreateDocument:self];
                link.uid = [uid stringByAppendingPathComponent: [dictLink objectForKey:field_Uid]];
                link.title = [dictLink objectForKey:field_LinkTitle];
#warning wrong date modified for link
                link.dateModified = document.dateModified;
                
#warning wrong author for link                
                link.author = document.author;
                
                [link.author addDocumentsObject:link];
                
                link.parent = document;
                
                link.path = [[document.path stringByAppendingPathComponent:@"links"] stringByAppendingPathComponent:link.uid];
                
                NSArray *linkAttachments = [dictLink objectForKey:field_Attachments];
                
                [self parseAttachments:link attachments: linkAttachments];
                
                [document addLinksObject: link];
            }
        }
        
        [[self dataSource] documentReaderCommit: self];
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
		BOOL x = (_networkQueue.requestsCount != 0);
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
- (void)fetchPage:(AttachmentPage *)page
{
    NSFileManager *df = [NSFileManager defaultManager];
    
    [df createDirectoryAtPath:page.path withIntermediateDirectories:TRUE 
                   attributes:nil error:nil];

    NSString *urlPattern;
    
    Attachment *attachment = page.attachment;
    Document *rootDocument = attachment.document;

#warning recursive links???
    if (rootDocument.parent) //link
    {
        rootDocument = rootDocument.parent;
        Document *link = rootDocument;
        
        urlPattern = [NSString stringWithFormat:urlLinkAttachmentFetchPageFormat, rootDocument.uid, link.uid, @"%@", @"%d"];
    }
    else
        urlPattern = [NSString stringWithFormat:urlAttachmentFetchPageFormat, rootDocument.uid, @"%@", @"%d"];
    
    NSString *anUrl = [NSString stringWithFormat:urlPattern, attachment.uid, [page.number intValue]];
    

    LNHttpRequest *r = [self makeRequestWithUrl: anUrl];
    
    [r setDownloadDestinationPath:page.pathImage];
    r.requestHandler = ^(ASIHTTPRequest *request) 
    {
        if ([request error] == nil  && [request responseStatusCode] == 200)
        {
            page.isFetchedValue = YES;
        }
        else
        {
            page.isFetchedValue = NO;
            NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
            //remove bugged response
            [df removeItemAtPath:[request downloadDestinationPath] error:NULL];
        }
        [[self dataSource] documentReaderCommit: self];
    };

    [_networkQueue addOperation:r];
}
- (void) parseResolution:(DocumentResolution *) resolution fromDictionary:(NSDictionary *) dictionary;
{
    resolution.text = [dictionary objectForKey:field_Text];
    resolution.author = [[self dataSource] documentReader:self personWithUid: [dictionary objectForKey:field_Author]];

    //performers
    [resolution removePerformers: resolution.performers]; //clean all performers
    
    NSArray *performers = [dictionary objectForKey:field_Performers];
    for (NSString *uid in performers)
    {
        NSString *u = [uid stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([u isEqualToString:@""])
             continue;
        Person *performer = [[self dataSource] documentReader:self personWithUid: uid];
        if (performer)
        {
            [resolution addPerformersObject: performer];
            [performer addResolutionsObject: resolution];
        }
        else
            NSLog(@"Unknown person: %@", uid);
    }
    
    NSDate *dDeadline = nil;
    NSString *sDeadline = [dictionary objectForKey:field_Deadline];
    if (sDeadline && ![sDeadline isEqualToString:@""])
        dDeadline = [parseFormatterSimple dateFromString:sDeadline];

    resolution.deadline = dDeadline;

    NSDictionary *parsedParentResolution = [dictionary objectForKey:field_ParentResolution];
    if (parsedParentResolution) 
    {
        DocumentResolution *parentResolution = [[self dataSource] documentReaderCreateResolution:self];
        [self parseResolution:parentResolution fromDictionary:parsedParentResolution];
        
#warning possibly wrong data (title, dateModified)
        if (!parentResolution.title)
            parentResolution.title = resolution.title;
        
        if (!parentResolution.dateModified)
            parentResolution.dateModified = resolution.dateModified;
        
        if (!parentResolution.uid)
            parentResolution.uid = [resolution.uid stringByAppendingString:@".parent"];

        
        resolution.parentResolution = parentResolution;
        parentResolution.parent = resolution;
    }
}
@end
