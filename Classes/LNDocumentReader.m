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
#import "DocumentLink.h"
#import "Attachment.h"
#import "LNHttpRequest.h"
#import "ASINetworkQueue.h"
#import "SBJsonParser.h"
#import "AttachmentPage.h"
#import "Person.h"
#import "PasswordManager.h"
#import "CommentAudio.h"
#import "Comment.h"
#import "AttachmentPagePainting.h"
#import "DocumentResolutionParent.h"
#import "DocumentResolutionAbstract.h"
#import "AZZUIImage.h"

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
static NSString *field_Modified    = @"modified";
static NSString *field_Subdocument = @"document";
static NSString *field_Deadline    = @"deadline";
static NSString *field_RegistrationDate    = @"regDate";
static NSString *field_RegistrationNumber    = @"regNumber";
static NSString *field_Form        = @"type";
static NSString *field_Uid         = @"id";
static NSString *field_Text        = @"text";
static NSString *field_Performers  = @"performers";
static NSString *field_ParentResolution  = @"parent";
static NSString *field_Attachments = @"files";
static NSString *field_AttachmentName = @"name";
static NSString *field_AttachmentPageCount = @"pageCount";
static NSString *field_AttachmentPagePainting = @"drawings";
static NSString *field_Links = @"links";
static NSString *field_LinkTitle = @"info";
static NSString *field_Status = @"status";
static NSString *field_Comment = @"userComment";
static NSString *field_CommentFile = @"file";
static NSString *field_Version = @"version";
static NSString *field_URL = @"url";
static NSString *field_Correspondents = @"corrs";
static NSString *field_Priority = @"priority";

static NSString *form_Resolution   = @"resolution";
static NSString *form_Signature    = @"document";
static NSString *url_FetchViewFormat     = @"%@/%@?ReadViewEntries&OutputFormat=json";
static NSString *url_FetchDocumentFormat = @"%@/document/%@";
    //document/id/file/file.id/page/pagenum
static NSString *url_AttachmentFetchPageFormat = @"%@/document/%@/file/%@/page/%@";

static NSString *url_AttachmentFetchPaintingFormat = @"/document/%@/file/%@/page/%@/drawing";
    //document/id/link/link.id/file/file.id/page/pagenum
static NSString *url_LinkAttachmentFetchPageFormat = @"%@/document/%@/link/%@/file/%@/page/%@";

static NSString *url_LinkAttachmentFetchPaintingFormat = @"/document/%@/link/%@/file/%@/page/%@/drawing";

@interface LNDocumentReader(Private)
- (void)fetchComplete:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)parseViewData:(NSString *) jsonString;
- (void)fetchDocuments;
- (void)parseDocumentData:(NSDictionary *) parsedDocument;
- (NSString *) documentDirectory:(NSString *) anUid;
- (void)fetchPage:(AttachmentPage *)painting;
- (void)fetchFile:(FileField *)page;
- (LNHttpRequest *) makeRequestWithUrl:(NSString *) url;
- (NSDictionary *) extractValuesFromViewColumn:(NSArray *)entryData;
- (void) parseResolution:(DocumentResolutionAbstract *) resolution fromDictionary:(NSDictionary *) dictionary;
- (void) fetchResources;
- (void) optimizeImage:(NSString *) path;
@end
static NSString* OperationCount = @"OperationCount";

@implementation LNDocumentReader
@synthesize isSyncing, dataSource, hasErrors;

- (id) initWithUrl:(NSString *) anUrl andViews:(NSArray *) views
{
    if ((self = [super init])) {
        
        baseUrl = [anUrl retain];
        
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
            [vs addObject: [NSString stringWithFormat:url_FetchViewFormat, baseUrl, vn]];
        
        viewUrls = vs;
        
        urlFetchDocumentFormat = [[NSString alloc] initWithFormat:url_FetchDocumentFormat, baseUrl, @"%@"];
        urlAttachmentFetchPageFormat = [[NSString alloc] initWithFormat:url_AttachmentFetchPageFormat, baseUrl, @"%@", @"%@", @"%@"];
        urlLinkAttachmentFetchPageFormat = [[NSString alloc] initWithFormat:url_LinkAttachmentFetchPageFormat, baseUrl, @"%@", @"%@", @"%@", @"%@"];

        statusDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:DocumentStatusDraft], @"draft",
                                                                              [NSNumber numberWithInt:DocumentStatusNew], @"new",
                                                                              [NSNumber numberWithInt:DocumentStatusDeclined], @"rejected",
                                                                              [NSNumber numberWithInt:DocumentStatusAccepted], @"approved",
                                                                              nil];
        [statusDictionary retain];
        
        _networkQueue = [[ASINetworkQueue alloc] init];
        [_networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
        [_networkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
        [_networkQueue setDelegate:self];
#warning only one request at time
        _networkQueue.maxConcurrentOperationCount = 1;
        [_networkQueue setShouldCancelAllRequestsOnFailure:NO];
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
    [parseFormatterDst release];
    [parseFormatterSimple release];

    [urlFetchDocumentFormat release];
    [urlAttachmentFetchPageFormat release];
    [urlLinkAttachmentFetchPageFormat release];
    [uidsToFetch release]; uidsToFetch = nil;
    [fetchedUids release]; fetchedUids = nil;
    [statusDictionary release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Methods
-(void) sync
{
    if (isSyncing) //prevent spam syncing requests
        return;

    [uidsToFetch release];
    
    [fetchedUids release];
    
    uidsToFetch = [[NSMutableSet alloc] init];
    
    fetchedUids = [[NSMutableSet alloc] init];
    
    viewsLeftToFetch = [viewUrls count];
    
    hasErrors = NO;
    
    allRequestsSent = NO;
    
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
                hasErrors = YES;
            }
            
            @synchronized (blockSelf)
            {
                viewsLeftToFetch--;
            }
            
            if (viewsLeftToFetch == 0 && !hasErrors) //all view fetched and no errors
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

            if (!_networkQueue.requestsCount)// nothing running
            {
                [self willChangeValueForKey:@"isSyncing"];
                isSyncing = NO;
                [self didChangeValueForKey:@"isSyncing"];
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
        
        NSString *version = [values objectForKey:field_Version];
        
#warning wrong document version
        
        version = @"unknown";
        
        NSAssert(version != nil, @"Unable to find version in view");

        Document *document = [[self dataSource] documentReader:self documentWithUid:uid];
        
        if (!document)
            [uidsToFetch addObject: uid];
        else if (![document.version isEqualToString: version])
            [uidsToFetch addObject: uid];
        
        [fetchedUids addObject: uid];
    }
}

- (void)fetchDocuments
{
    __block LNDocumentReader *blockSelf = self;
    
    documentsLeftToFetch = [uidsToFetch count];
    
    if (documentsLeftToFetch)
    {
        for (NSString *uid in uidsToFetch)
        {
            NSString *anUrl = [NSString stringWithFormat:urlFetchDocumentFormat, uid];
            LNHttpRequest *request = [blockSelf makeRequestWithUrl: anUrl];
            
            request.requestHandler = ^(ASIHTTPRequest *request) {
                if ([request error] == nil  && [request responseStatusCode] == 200) //remove document if error
                {
                    NSString *jsonString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
                    SBJsonParser *json = [[SBJsonParser alloc] init];
                    NSError *error = nil;
                    NSDictionary *parsedDocument = [json objectWithString:jsonString error:&error];
                    [jsonString release];
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
                    [blockSelf fetchResources];
                    
                    blockSelf->allRequestsSent = YES;
                }
            };
            [_networkQueue addOperation:request];
        }
    }
    else
    {
        [self fetchResources];
        allRequestsSent = YES;
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
        }

        if (!exists)
            [[self dataSource] documentReader:self removeObject: attachment];
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
            attachment = [[self dataSource] documentReader:self createEntity:[Attachment class]];
            attachment.title = [dictAttachment objectForKey:field_AttachmentName];
            attachment.uid = [dictAttachment objectForKey:field_Uid];
            attachment.document = document;
            
            [[self dataSource] documentReaderCommit: self];
            
            NSUInteger pageCount = [[dictAttachment objectForKey:field_AttachmentPageCount] intValue];
            
            for (NSUInteger i = 0; i < pageCount ; i++) //create page stubs
            {
                AttachmentPage *page = [[self dataSource] documentReader:self createEntity:[AttachmentPage class]];
                page.numberValue = i;
                page.syncStatusValue = SyncStatusNeedSyncFromServer;
                AttachmentPagePainting *painting = [[self dataSource] documentReader:self createEntity:[AttachmentPagePainting class]];
                painting.path = [page.path stringByAppendingPathComponent:@"drawings.png"];
                
                if ([document isKindOfClass:[DocumentLink class]])
                {
                    DocumentLink *link = (DocumentLink *) document;
                    painting.url = [NSString stringWithFormat:url_LinkAttachmentFetchPaintingFormat, link.document.uid, link.uid, attachment.uid, page.number];
                }
                else
                    painting.url = [NSString stringWithFormat:url_AttachmentFetchPaintingFormat, document.uid, attachment.uid, page.number];
                
                painting.syncStatusValue = SyncStatusSynced;

                page.painting = painting;

                page.attachment = attachment;
            }
        }
        
        NSArray *paintings = [dictAttachment objectForKey:field_AttachmentPagePainting];
        for (NSNumber *pageNumber in paintings)
        {
            NSSet *pages = attachment.pages;
            AttachmentPage *page = nil;
            for (AttachmentPage *p in pages)
            {
                if ([p.number isEqualToNumber: pageNumber])
                {
                    page = p;
                    break;
                }
            }
            page.painting.syncStatusValue = SyncStatusNeedSyncFromServer;
        }
        [[self dataSource] documentReaderCommit: self];
    }
}

- (void)parseDocumentData:(NSDictionary *) parsedDocument
{
    @synchronized (self)
    {
        NSFileManager *df = [NSFileManager defaultManager];
        
        NSString *form = [parsedDocument objectForKey:field_Form];
        NSString *uid = [parsedDocument objectForKey:field_Uid];
        
        NSDictionary *subDocument = [parsedDocument objectForKey:field_Subdocument];
        
        NSNumber *documentStatus;
        
        NSString *author = [parsedDocument objectForKey:field_Author];
        
        if (!author)
        {
            NSLog(@"no author, document skipped: %@", uid);
            return;
        }
        
        NSString *stringStatus = [parsedDocument objectForKey:field_Status];
        
        documentStatus = [statusDictionary objectForKey:stringStatus];
        if (!documentStatus)
        {
            NSLog(@"unknown document status '%@', document skipped: %@", stringStatus, uid);
            return;
        }
        
        NSString *dateModifiedString = [parsedDocument objectForKey:field_Modified];
#warning wrong date modified
        dateModifiedString = @"20101022T183214,25+04";
        
        NSDate *dateModified = nil;

        if (!dateModifiedString || !(dateModified = [parseFormatterDst dateFromString:dateModifiedString]))
        {
            NSLog(@"unknown document date modified, document skipped: %@", uid);
            return;
        }

        NSString *documentVersion = [parsedDocument objectForKey:field_Version];
        
        if (!documentVersion)
        {
            NSLog(@"unknown document version, document skipped: %@", uid);
            return;
        }
        
        Document *document = [[self dataSource] documentReader:self documentWithUid:uid];
        
        if (!document ) //create new document
        {
            if ([form isEqualToString:form_Resolution])
                document = [[self dataSource] documentReader:self createEntity:[DocumentResolution class]];
            else if ([form isEqualToString:form_Signature])
                document = [[self dataSource] documentReader:self createEntity:[DocumentSignature class]];
            else
            {
                NSLog(@"wrong form, document skipped: %@ %@", uid, form);
                return;
            }

            document.path = [self documentDirectory: uid];
            
            Comment *comment = [[self dataSource] documentReader:self createEntity:[Comment class]];
            CommentAudio *audio = [[self dataSource] documentReader:self createEntity:[CommentAudio class]];
            audio.path = [[document.path stringByAppendingPathComponent:@"comments"] stringByAppendingPathComponent:@"audioComment.caf"];
            
            [df createDirectoryAtPath:[audio.path stringByDeletingLastPathComponent] withIntermediateDirectories:TRUE 
                           attributes:nil error:nil];


            
            comment.audio = audio;
            audio.comment = comment;
            
            document.comment = comment;
            comment.document = document;
        }
        
        document.version = documentVersion;
        
        document.syncStatus = SyncStatusSynced;

        document.author = author;
        
        document.status = documentStatus;
        
        document.isReadValue = (document.statusValue != DocumentStatusNew);
        
        document.uid = uid;
        
        document.title = [subDocument objectForKey:field_Title];
        
        document.dateModified = dateModified;
        
        document.correspondents = [subDocument objectForKey:field_Correspondents];

        NSNumber *priority = [parsedDocument objectForKey:field_Priority];
#warning wrong priority
        priority = [NSNumber numberWithInt:0];
        
        if ([priority intValue]>0)
            document.priorityValue = DocumentPriorityHigh;
        else
            document.priorityValue = DocumentPriorityNormal;
        
        
        NSDate *dDegistrationDate = nil;
        NSString *sDegistrationDate = [subDocument objectForKey:field_RegistrationDate];
        if (sDegistrationDate && ![sDegistrationDate isEqualToString:@""])
            dDegistrationDate = [parseFormatterSimple dateFromString:sDegistrationDate];
        else
            dDegistrationDate = document.dateModified;
        
        document.registrationDate = dDegistrationDate;

        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
        
        NSDateComponents *comps = [calendar components:unitFlags fromDate:document.registrationDate];
        
        document.registrationDateStripped = [calendar dateFromComponents:comps];

        //registrationNumber
        NSString *registrationNumber = [subDocument objectForKey:field_RegistrationNumber];
        
        if (registrationNumber && ![registrationNumber isEqualToString:@""])
            document.registrationNumber = registrationNumber;
        
        
        if ([document isKindOfClass:[DocumentResolution class]]) 
        {
            DocumentResolution *resolution = (DocumentResolution *)document;
            [self parseResolution:resolution fromDictionary:parsedDocument];

        }
        
        //parse comment
        NSDictionary *userComment = [parsedDocument valueForKey:field_Comment];
        if (userComment && [userComment count])
        {
            Comment *comment = document.comment;
            comment.text = [userComment objectForKey:field_Text];
            NSDictionary *commentFile = [userComment valueForKey:field_CommentFile];
            if (commentFile)
            {
                CommentAudio *audio = comment.audio;
                
                NSString *version = [commentFile valueForKey:field_Version];
                NSString *url = [commentFile valueForKey:field_URL];
                if (![audio.version isEqualToString: version])
                {
                    audio.url = url;
                    audio.syncStatusValue = SyncStatusNeedSyncFromServer;
                }
            }
        }
        
        //parse attachments
        NSArray *attachments = [subDocument objectForKey:field_Attachments];
        
        [self parseAttachments:document attachments: attachments];
        
        //parse links
        NSArray *links = [subDocument objectForKey:field_Links];
        
        NSSet *existingLinks = document.links;
        
        //remove obsoleted attachments
        for (DocumentLink *link in existingLinks)
        {
            BOOL  exists = NO;
            for (NSDictionary *dictLink in links)
            {
                NSString *linkUid = [dictLink objectForKey:field_Uid];
                if ([link.index isEqualToString :linkUid])
                {
                    exists = YES;
                    break;
                }
            }
            
            if (!exists)
                [[self dataSource] documentReader:self removeObject: link];
        }
        
        //add new links
        existingLinks = document.links;
        
        for(NSDictionary *dictLink in links)
        {
            NSString *linkUid = [dictLink objectForKey:field_Uid];
            
            DocumentLink *link = nil;
            
            for (DocumentLink *l in existingLinks)
            {
                if ([l.index isEqualToString: linkUid])
                {
                    link = l;
                    break;
                }
            }
            
            if (!link) //create new link
            {
                link = [[self dataSource] documentReader:self createEntity:[DocumentLink class]];

                link.index = [dictLink objectForKey:field_Uid];
                
                link.uid = [uid stringByAppendingPathComponent: [dictLink objectForKey:field_Uid]];

                link.title = [dictLink objectForKey:field_LinkTitle];

                link.dateModified = document.dateModified;
                
                link.author = document.author;
                
                link.document = document;
                
                link.path = [[document.path stringByAppendingPathComponent:@"links"] stringByAppendingPathComponent:link.uid];
                
                [[self dataSource] documentReaderCommit: self];
                
                NSArray *linkAttachments = [dictLink objectForKey:field_Attachments];
                
                [self parseAttachments:link attachments: linkAttachments];
            }
        }
        
        [[self dataSource] documentReaderCommit: self];
    }
}

- (LNHttpRequest *) makeRequestWithUrl:(NSString *) anUrl
{
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString: anUrl]];
    request.delegate = self;
    return request;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &OperationCount)
    {
		BOOL x = !allRequestsSent || (_networkQueue.requestsCount != 0);
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

    if ([rootDocument isKindOfClass:[DocumentLink class]]) //link
    {
        DocumentLink *link = (DocumentLink *)rootDocument;

        rootDocument = link.document;
        
        urlPattern = [NSString stringWithFormat:urlLinkAttachmentFetchPageFormat, rootDocument.uid, link.index, @"%@", @"%d"];
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
            [self optimizeImage:page.pathImage];
            page.syncStatusValue = SyncStatusSynced;
        }
        else
        {
            NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
            //remove bugged response
            [df removeItemAtPath:[request downloadDestinationPath] error:NULL];
        }
        [[self dataSource] documentReaderCommit: self];
    };

    [_networkQueue addOperation:r];
}

- (void)fetchFile:(FileField *)file
{
    NSFileManager *df = [NSFileManager defaultManager];
    
    [df createDirectoryAtPath:[file.path stringByDeletingLastPathComponent] withIntermediateDirectories:TRUE 
                   attributes:nil error:nil];
    
    NSString *anUrl = [baseUrl stringByAppendingString:file.url];
    
    
    LNHttpRequest *r = [self makeRequestWithUrl: anUrl];
    
    [r setDownloadDestinationPath:file.path];
    r.requestHandler = ^(ASIHTTPRequest *request) 
    {
        if ([request error] == nil  && [request responseStatusCode] == 200)
        {

            if ([file isKindOfClass:[AttachmentPagePainting class]])
                [self optimizeImage:file.path];
            
            file.syncStatusValue = SyncStatusSynced;
        }
        else
        {
            NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
            //remove bugged response
            [df removeItemAtPath:[request downloadDestinationPath] error:NULL];
        }
        [[self dataSource] documentReaderCommit: self];
    };
    
    [_networkQueue addOperation:r];
}

- (void) parseResolution:(DocumentResolutionAbstract *) aResolution fromDictionary:(NSDictionary *) dictionary
{
    aResolution.text = [dictionary objectForKey:field_Text];
    aResolution.author = [dictionary objectForKey:field_Author];

    NSDate *dDeadline = nil;
    NSString *sDeadline = [dictionary objectForKey:field_Deadline];
    if (sDeadline && ![sDeadline isEqualToString:@""])
        dDeadline = [parseFormatterSimple dateFromString:sDeadline];
    
    aResolution.deadline = dDeadline;

    NSArray *performers = [dictionary objectForKey:field_Performers];

    if ([aResolution isKindOfClass:[DocumentResolution class]])
    {
        DocumentResolution *resolution = (DocumentResolution *)aResolution;

        //performers
        NSArray *performers = [dictionary objectForKey:field_Performers];
        for (NSString *uid in performers)
        {
            NSString *u = [uid stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([u isEqualToString:@""])
                continue;
            Person *performer = [[self dataSource] documentReader:self personWithUid: uid];
            if (performer)
                [performer addResolutionsObject: resolution];
            else
                NSLog(@"Unknown person: %@", uid);
        }
        
        //parent resolution
        NSDictionary *parsedParentResolution = [dictionary objectForKey:field_ParentResolution];
        if (parsedParentResolution) 
        {
            DocumentResolutionParent *parentResolution = [[self dataSource] documentReader:self createEntity:[DocumentResolutionParent class]];
            [self parseResolution:parentResolution fromDictionary:parsedParentResolution];
            
            if (!parentResolution.title)
                parentResolution.title = resolution.title;
            
            if (!parentResolution.dateModified)
                parentResolution.dateModified = resolution.dateModified;
            
            if (!parentResolution.uid)
                parentResolution.uid = [resolution.uid stringByAppendingString:@"/parentResolution"];
            
            resolution.parentResolution = parentResolution;
            parentResolution.resolution = resolution;
        }
    }
    else if ([aResolution isKindOfClass:[DocumentResolutionParent class]])
    {
        //performers
        DocumentResolutionParent *resolution = (DocumentResolutionParent *)aResolution;
        resolution.performers = performers;
    }
}
- (void) fetchResources
{
    NSArray *unfetchedPages = [self.dataSource documentReaderUnfetchedPages:self];
    for(AttachmentPage *page in unfetchedPages)
        [self fetchPage:page];
    
    NSArray *unfetchedFiles = [self.dataSource documentReaderUnfetchedFiles:self];
    for(FileField *file in unfetchedFiles)
        [self fetchFile:file];
}

- (void) optimizeImage:(NSString *) path
{
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    CGSize size = image.size;
    
    CGFloat maxSize = MAX(size.width, size.height);

    CGFloat scale = 0.0f;
    
    if (maxSize > 1024.0f)
        scale = 1024.0f / maxSize;
    
    if (scale != 0.0f)
    {
        UIImage *scaledImage = [image scaleToSize:CGSizeMake(size.width * scale, size.height * scale)];
        NSData *data = UIImagePNGRepresentation(scaledImage);
        [data writeToFile: path atomically:YES];
    }
}
@end
