//
//  LNDataSource.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDocumentReader.h"
#import "DocumentWithResources.h"
#import "DocumentResolution.h"
#import "DocumentSignature.h"
#import "DocumentLink.h"
#import "Attachment.h"
#import "AttachmentPage.h"
#import "Person.h"
#import "CommentAudio.h"
#import "AttachmentPagePainting.h"
#import "DocumentResolutionParent.h"
#import "DocumentResolutionAbstract.h"

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
static NSString *field_Editable    = @"editable";
static NSString *field_Created    = @"created";
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
static NSString *field_Links = @"links";
static NSString *field_LinkTitle = @"info";
static NSString *field_Status = @"status";
static NSString *field_CommentAudio = @"audio";
static NSString *field_Version = @"version";
static NSString *field_DocVersion = @"docVersion";
static NSString *field_ContentVersion = @"contentVersion";
static NSString *field_Correspondents = @"corrs";
static NSString *field_Priority = @"priority";
static NSString *field_PageNumber = @"pageNum";
static NSString *field_Managed = @"hasControl";
static NSString *field_Date = @"date";
static NSString *field_Resources = @"resources";
static NSString *field_Drawing = @"drawing";

static NSString *form_Resolution   = @"resolution";
static NSString *form_Signature    = @"document";
static NSString *url_FetchViewFormat     = @"%@/%@?ReadViewEntries&OutputFormat=json";
static NSString *url_FetchDocumentFormat = @"%@/document/%@";

static NSString *url_AttachmentFetchPaintingFormat = @"/document/%@/file/%@/page/%@/drawing";

static NSString *url_LinkAttachmentFetchPaintingFormat = @"/document/%@/link/%@/file/%@/page/%@/drawing";

static NSString *url_AudioCommentFormat = @"/document/%@/audio";

@interface LNDocumentReader(Private)
- (void)parseViewData:(id) parsedData;
- (void)fetchDocuments;
- (void)parseDocumentData:(NSDictionary *) parsedDocument;
- (NSString *) documentDirectory:(NSString *) anUid;
- (NSDictionary *) extractValuesFromViewColumn:(NSArray *)entryData;
- (void) parseResolution:(DocumentResolutionAbstract *) resolution fromDictionary:(NSDictionary *) dictionary;
- (void) parseResources:(DocumentWithResources *) document fromDictionary:(NSDictionary *) dictionary;
- (void) parseLinks:(DocumentWithResources *) document fromArray:(NSArray *) links;
- (void) parseAttachmentResources:(Attachment *) attachment fromArray:(NSArray *) resources;
@end

@implementation LNDocumentReader
@synthesize dataSource, views;

-(void) setViews:(NSArray *)vs
{
    if (views == vs)
        return;
    [views release];
    views = [vs retain];
    
    NSMutableArray *vsu = [[NSMutableArray alloc] initWithCapacity: [views count]];
    
    NSString *serverUrl = self.serverUrl;
    
    for (NSString *vn in views)
        [vsu addObject: [NSString stringWithFormat:url_FetchViewFormat, serverUrl, vn]];

    [views release];
    viewUrls = vsu;
}

- (id)init 
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

        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        urlFetchDocumentFormat = [[NSString alloc] initWithFormat:url_FetchDocumentFormat, self.serverUrl, @"%@"];

        statusDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:DocumentStatusDraft], @"draft",
                                                                              [NSNumber numberWithInt:DocumentStatusNew], @"new",
                                                                              [NSNumber numberWithInt:DocumentStatusDeclined], @"rejected",
                                                                              [NSNumber numberWithInt:DocumentStatusAccepted], @"accepted",
                                                                              nil];
        [statusDictionary retain];
    }
    return self;
}

#pragma mark -
#pragma mark Memory management
-(void)dealloc
{
    [_databaseDirectory release];
	self.dataSource = nil;
    [viewUrls release];
    [parseFormatterDst release];
    [parseFormatterSimple release];

    [urlFetchDocumentFormat release];
    [uidsToFetch release]; uidsToFetch = nil;
    [fetchedUids release]; fetchedUids = nil;
    [statusDictionary release];
    [numberFormatter release]; numberFormatter = nil;
    self.views = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Methods
-(void) run
{
    [uidsToFetch release];
    
    [fetchedUids release];
    
    uidsToFetch = [[NSMutableSet alloc] init];
    
    fetchedUids = [[NSMutableSet alloc] init];
    
    viewsLeftToFetch = [viewUrls count];
    
    
    for (NSString *url in viewUrls)
    {
        __block LNDocumentReader *blockSelf = self;
        
        [self jsonRequestWithUrl:url 
                      andHandler:^(BOOL err, id response)
        {
            if (err)
                return;
            
            [blockSelf parseViewData:response];
            
            @synchronized (blockSelf)
            {
                viewsLeftToFetch--;
            }
            
            if (viewsLeftToFetch == 0) //all view fetched and no errors
            {
                if (!self.hasError)
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
                    [[blockSelf dataSource]  documentReaderCommit: self];
                    if ([blockSelf->uidsToFetch count])
                        [blockSelf fetchDocuments];
                }
            }
        }];
    }
}

- (void)purgeCache
{
    NSFileManager *df = [NSFileManager defaultManager];
    [df removeItemAtPath:_databaseDirectory error:NULL];
}

@end

@implementation LNDocumentReader(Private)

- (void)parseViewData:(id) parsedView
{
    NSArray *entries = [parsedView objectForKey:view_RootEntry]; 
    for (NSDictionary *entry in entries) 
    {
        NSString *uid = [entry objectForKey:view_EntryUid];
            //new document
        NSArray *entryData = [entry objectForKey:view_EntryData];
        
        NSDictionary *values = [self extractValuesFromViewColumn: entryData];
#warning wrong column name        
        NSString *docVersion = [values objectForKey:field_Version];
        
        NSAssert(docVersion != nil, @"Unable to find version in view");

        Document *document = [[self dataSource] documentReader:self documentWithUid:uid];
        
        if (!document)
            [uidsToFetch addObject: uid];
        else if (![document.docVersion isEqualToString: docVersion])
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
            NSString *url = [NSString stringWithFormat:urlFetchDocumentFormat, uid];
            [self jsonRequestWithUrl:url 
                          andHandler:^(BOOL err, id response)
             {
                 if (err)
                     blockSelf.hasError = NO; //ignore error
                 else
                    [blockSelf parseDocumentData:response];
                 
                 @synchronized (blockSelf)
                 {
                     documentsLeftToFetch--;
                 }
             }];
        }
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
                
                painting.path = [page.path stringByAppendingPathComponent:@"drawings.png"];
            }
        }
        
        [self parseAttachmentResources:attachment fromArray:[dictAttachment objectForKey:field_Resources]];
        
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
            AZZLog(@"no author, document skipped: %@", uid);
            return;
        }
        
        NSString *stringStatus = [parsedDocument objectForKey:field_Status];
        
        documentStatus = [statusDictionary objectForKey:stringStatus];
        if (!documentStatus)
        {
            AZZLog(@"unknown document status '%@', document skipped: %@", stringStatus, uid);
            return;
        }
        
        NSString *dateModifiedString = [parsedDocument objectForKey:field_Modified];
        
        NSDate *dateModified;

        if (!dateModifiedString || !(dateModified = [parseFormatterDst dateFromString:dateModifiedString]))
        {
            AZZLog(@"unknown document date modified, document skipped: %@", uid);
            return;
        }

        NSString *dateCreatedString = [parsedDocument objectForKey:field_Created];
        
        NSDate *dateCreated;
        
        if (!dateCreatedString || !(dateCreated = [parseFormatterDst dateFromString:dateCreatedString]))
        {
            AZZLog(@"unknown document date created, document skipped: %@", uid);
            return;
        }
        
        NSString *dateString = [parsedDocument objectForKey:field_Date];
        
        NSDate *date;
        
        if (!dateString || !(date = [parseFormatterDst dateFromString:dateString]))
        {
            AZZLog(@"unknown document date, document skipped: %@", uid);
            return;
        }
        
        
        NSString *documentVersion = [parsedDocument objectForKey:field_DocVersion];
        
        if (!documentVersion)
        {
            AZZLog(@"unknown docVersion, document skipped: %@", uid);
            return;
        }
        
        NSString *contentVersion = [parsedDocument objectForKey:field_ContentVersion];

        if (!contentVersion)
        {
            AZZLog(@"unknown contentVersion, document skipped: %@", uid);
            return;
        }
        
        DocumentWithResources *document = (DocumentWithResources *)[[self dataSource] documentReader:self documentWithUid:uid];
        
        if (!document ) //create new document
        {
            if ([form isEqualToString:form_Resolution])
                document = [[self dataSource] documentReader:self createEntity:[DocumentResolution class]];
            else if ([form isEqualToString:form_Signature])
                document = [[self dataSource] documentReader:self createEntity:[DocumentSignature class]];
            else
            {
                AZZLog(@"wrong form, document skipped: %@ %@", uid, form);
                return;
            }

            document.path = [self documentDirectory: uid];
            
            CommentAudio *audio = [[self dataSource] documentReader:self createEntity:[CommentAudio class]];
            audio.path = [[document.path stringByAppendingPathComponent:@"comments"] stringByAppendingPathComponent:@"audioComment.caf"];
            [df createDirectoryAtPath:[audio.path stringByDeletingLastPathComponent] withIntermediateDirectories:TRUE 
                           attributes:nil error:nil];


            
            audio.document = document;
        }
        
        document.docVersion = documentVersion;
        
        document.syncStatusValue = SyncStatusSynced;
        
        if (![document.contentVersion isEqualToString:contentVersion])
        {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
            NSDateComponents *comps;
            
            document.contentVersion = contentVersion;
            
            document.created = dateCreated;
            
            comps = [calendar components:unitFlags fromDate:document.created];
            document.created = [calendar dateFromComponents:comps];

            document.modified = dateModified;
            
            document.date = date;

            comps = [calendar components:unitFlags fromDate:document.date];
            document.dateStripped = [calendar dateFromComponents:comps];

            document.isEditable = [parsedDocument objectForKey:field_Editable];

            document.author = author;
            
            document.status = documentStatus;
            
            document.isReadValue = (document.statusValue != DocumentStatusNew);
            
            document.uid = uid;
            
            document.title = [subDocument objectForKey:field_Title];
            
            document.correspondents = [subDocument objectForKey:field_Correspondents];
            
            document.text = [parsedDocument objectForKey:field_Text];
            
            NSNumber *priority = [parsedDocument objectForKey:field_Priority];
            
            if ([priority intValue]>0)
                document.priorityValue = DocumentPriorityHigh;
            else
                document.priorityValue = DocumentPriorityNormal;
            
            if ([document isKindOfClass:[DocumentResolution class]]) 
            {
                DocumentResolution *resolution = (DocumentResolution *)document;
                resolution.isManagedValue = [[parsedDocument valueForKey:field_Managed] boolValue];

                NSDate *dDegistrationDate = nil;
                NSString *sDegistrationDate = [subDocument objectForKey:field_RegistrationDate];
                if (sDegistrationDate && ![sDegistrationDate isEqualToString:@""])
                    dDegistrationDate = [parseFormatterSimple dateFromString:sDegistrationDate];
                
                resolution.regDate = dDegistrationDate;
                
                resolution.regNumber = [subDocument objectForKey:field_RegistrationNumber];
                
                [self parseResolution:resolution fromDictionary:parsedDocument];
                
            }
            
        }
        

        [self parseResources:document fromDictionary:[parsedDocument valueForKey:field_Resources]];
        
        [self parseAttachments:document attachments: [subDocument objectForKey:field_Attachments]];
        
        [self parseLinks:document fromArray:[subDocument objectForKey:field_Links]];
        
        [[self dataSource] documentReaderCommit: self];
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
                AZZLog(@"Unknown person: %@", uid);
        }
        
        //parent resolution
        NSDictionary *parsedParentResolution = [dictionary objectForKey:field_ParentResolution];
        if (parsedParentResolution) 
        {
            DocumentResolutionParent *parentResolution = [[self dataSource] documentReader:self createEntity:[DocumentResolutionParent class]];
            [self parseResolution:parentResolution fromDictionary:parsedParentResolution];
            
            if (!parentResolution.title)
                parentResolution.title = resolution.title;
            
            if (!parentResolution.uid)
                parentResolution.uid = [resolution.uid stringByAppendingString:@"/parentResolution"];
            
            resolution.parentResolution = parentResolution;
            parentResolution.resolution = resolution;
            
            NSDate *dDate = nil;
            NSString *sDate = [parsedParentResolution objectForKey:field_Date];
            if (sDate && ![sDate isEqualToString:@""])
                dDate = [parseFormatterSimple dateFromString:sDate];
            
            parentResolution.date = dDate;
        }
    }
    else if ([aResolution isKindOfClass:[DocumentResolutionParent class]])
    {
        //performers
        DocumentResolutionParent *resolution = (DocumentResolutionParent *)aResolution;
        resolution.performers = performers;
    }
}

- (void) parseResources:(DocumentWithResources *) document fromDictionary:(NSDictionary *) dictionary
{
    NSFileManager *df = [NSFileManager defaultManager];

        //parse audio
    NSString *audioVersion = [dictionary valueForKey:field_CommentAudio];
    CommentAudio *audio = document.audio;
    if (audioVersion)
    {
        NSString *version = [dictionary valueForKey:field_Version];
        if (!([audio.version isEqualToString: version]))
        {
            audio.version = version;
            audio.url = [NSString stringWithFormat:url_AudioCommentFormat, document.uid];
            audio.syncStatusValue = SyncStatusNeedSyncFromServer;
        }
    }
    else
    {
        [df removeItemAtPath:audio.path error:NULL];
        audio.syncStatusValue = SyncStatusSynced;
    }
}

- (void) parseLinks:(DocumentWithResources *) document fromArray:(NSArray *) links
{
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
            
            link.uid = [document.uid stringByAppendingPathComponent:[@"links" stringByAppendingPathComponent:[dictLink objectForKey:field_Uid]]];
            
            link.title = [dictLink objectForKey:field_LinkTitle];
            
            link.document = document;
            
            link.path = [[document.path stringByAppendingPathComponent:@"links"] stringByAppendingPathComponent:link.uid];
            
            [[self dataSource] documentReaderCommit: self];
            
            NSArray *linkAttachments = [dictLink objectForKey:field_Attachments];
            
            [self parseAttachments:link attachments: linkAttachments];
        }
    }
    
}

- (void) parseAttachmentResources:(Attachment *) attachment fromArray:(NSArray *) resources
{
    NSFileManager *df = [NSFileManager defaultManager];

    NSMutableSet *paintingsFromServer = [[NSMutableSet alloc] initWithCapacity:[resources count]];
    
    for (NSDictionary *painting in resources)
    {
        NSString *paintingVersion = [painting valueForKey:field_Drawing];

        NSNumber *paintingPageNumber = [painting valueForKey:field_PageNumber];
        
        if (!(paintingVersion && 
              paintingPageNumber && 
              [paintingPageNumber intValue] >= 0 && 
              [paintingPageNumber intValue] < [attachment.pages count]))
        {
            AZZLog(@"invalid drawings object: %@/%@/%@", attachment.document.uid, attachment.uid, paintingPageNumber);
            continue;
        }
        
        AttachmentPage *page = [attachment.pagesOrdered objectAtIndex:[paintingPageNumber intValue]];
        
        AttachmentPagePainting *painting = page.painting;
        
        if (!([painting.version isEqualToString:paintingVersion]))
        {
            painting.version = paintingVersion;
            painting.syncStatusValue = SyncStatusNeedSyncFromServer;
        }
        
        [paintingsFromServer addObject:paintingPageNumber];
    }
    
    for (AttachmentPage *page in attachment.pages)
    {
        if (![paintingsFromServer containsObject:page.number])
        {
            [df removeItemAtPath:page.painting.path error:NULL];
            page.painting.syncStatusValue = SyncStatusSynced;
        }
    }
    
    [paintingsFromServer release];
}
@end
