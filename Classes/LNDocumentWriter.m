//
//  LNDocumentSaver.m
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 22.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDocumentWriter.h"
#import "DocumentWithResources.h"
#import "DocumentResolution.h"
#import "DocumentSignature.h"
#import "DocumentRoot.h"
#import "DataSource.h"
#import "Person.h"
#import "FileField.h"
#import "CommentAudio.h"
#import "AttachmentPagePainting.h"
#import "Attachment.h"
#import "AttachmentPage.h"

static NSString* kFieldUid = @"id";
static NSString* kFieldDeadline = @"deadline";
static NSString* kFieldPerformers = @"performers";
static NSString* kFieldText = @"text";
static NSString* kFieldFile = @"file";
static NSString* kPostDataField = @"json";
static NSString* kFieldParent = @"parent";
static NSString* kFieldDocument = @"document";
static NSString* kFieldPage = @"pageNum";
static NSString* kFieldAudio = @"audio";
static NSString* kFieldDrawing = @"drawing";
static NSString* kFieldManaged = @"hasControl";
static NSString* kFieldDocVersion = @"docVersion";
static NSString* kFieldContentVersion = @"contentVersion";
static NSString* kFieldStatus = @"status";
static NSString* kFieldDate = @"date";
static NSString* kFieldEditable = @"editable";

@interface LNDocumentWriter(Private)
- (void) syncDocument:(DocumentRoot *) document;
- (void) syncFile:(FileField *) file;
- (NSString *)postFileUrl;
- (NSString *)postFileField;
- (void) discardDocument:(DocumentRoot *) document;
- (void) syncDocuments;
@end


@implementation LNDocumentWriter
@synthesize unsyncedDocuments, unsyncedFiles;

- (id) init
{
    if ((self = [super init])) {
        parseFormatterDst = [[NSDateFormatter alloc] init];
            //2010.11.25T13:19:42Z+0000
        [parseFormatterDst setDateFormat:@"yyyy.MM.dd'T'HH:mm:ss'Z'Z"];
        
        parseFormatterSimple = [[NSDateFormatter alloc] init];
        //20100811
        [parseFormatterSimple setDateFormat:@"yyyyMMdd"];
    }
    return self;
}


- (void) run
{
    NSError *error = nil;

    if (![unsyncedFiles performFetch:&error])
		NSAssert1(error == nil, @"Unhandled error executing unsynced files: %@", [error localizedDescription]);
    
    [resourcesToSync release];
    
    resourcesToSync = [NSMutableArray arrayWithArray:[unsyncedFiles fetchedObjects]];
    
    [resourcesToSync retain];
    
    [self syncFile:[resourcesToSync lastObject]];
}

- (void)dealloc 
{
    [parseFormatterSimple release]; parseFormatterSimple = nil;
    
    [parseFormatterDst release]; parseFormatterDst = nil;
    
    [postFileUrl release]; postFileUrl = nil;
    
    [postFileField release]; postFileField = nil;
    
    self.unsyncedDocuments = nil;
    
    self.unsyncedFiles = nil;
    
    [resourcesToSync release]; resourcesToSync = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Private
- (void) syncDocument:(DocumentRoot *) document
{
    NSMutableDictionary *dictDocument = [NSMutableDictionary dictionaryWithCapacity: 6];
    
    [dictDocument setObject:document.uid forKey:kFieldUid];
    
    [dictDocument setObject:document.docVersion forKey:kFieldDocVersion];
    
    NSString *status;
    
    switch (document.statusValue)
    {
        case DocumentStatusNew:
        case DocumentStatusDraft:
            status = @"draft";
            break;
        case DocumentStatusAccepted:
            status = @"accepted";
            [dictDocument setObject:[parseFormatterDst stringFromDate:document.date] forKey:kFieldDate];
            break;
        case DocumentStatusDeclined:
            status = @"rejected";
            [dictDocument setObject:[parseFormatterDst stringFromDate:document.date] forKey:kFieldDate];
            break;
        default:
            AZZLog(@"unknown status %d dor document %@", document.statusValue, document.uid);
            return;
    }
    
    [dictDocument setObject:status forKey:kFieldStatus];
    
    if ([document isKindOfClass: [DocumentResolution class]])
    {
        DocumentResolution *resolution = (DocumentResolution *) document;
        
        if (resolution.deadline)
            [dictDocument setObject:[parseFormatterSimple stringFromDate:resolution.deadline] forKey:kFieldDeadline];
        
        NSArray *performers = resolution.performersOrdered;
        NSUInteger performersCount = [performers count];
        if (performersCount)
        {
            NSMutableArray *performersArray = [[NSMutableArray alloc] initWithCapacity: performersCount];
            for(Person *performer in performers)
                [performersArray addObject:performer.uid];

            [dictDocument setObject:performersArray forKey:kFieldPerformers];
            
            [performersArray release];
        }
        
        //for boolena in json - [NSNumber numberWithBool ...]
        [dictDocument setObject:[NSNumber numberWithBool:resolution.isManagedValue] forKey:kFieldManaged];
    }
    
    if (document.text)
        [dictDocument setObject:document.text forKey:kFieldText];
    
    __block LNDocumentWriter *blockSelf = self;
    
    [self jsonPostRequestWithUrl:self.postFileUrl
                        postData:[NSDictionary dictionaryWithObjectsAndKeys:dictDocument, kPostDataField, nil]
                           files:nil 
                      andHandler:^(NSError *err, id response)
    {
        if (err)
        {
            if (isAppError(err, ERROR_IPAPKA_CONFLICT))
                [blockSelf discardDocument:document];
            return;
        }
        
        NSString *contentVersion = [response valueForKey:kFieldContentVersion];
        
        NSString *docVersion = [response valueForKey:kFieldDocVersion];
        
        NSNumber *editable = [response valueForKey:kFieldEditable];
        
        if (docVersion == nil || contentVersion == nil || editable == nil)
        {
            AZZLog(@"error parsing response (editable, docVersion or contentVersion is null): %@", response);
            blockSelf.hasError = YES;
            return;
        }
        document.docVersion = docVersion;
        document.contentVersion = contentVersion;
        document.syncStatusValue = SyncStatusSynced;
        document.isEditable = editable;
        
        [[DataSource sharedDataSource] commit];
    }];  
}

- (void) syncFile:(FileField *) file
{
    if (!file)
    {
        [self syncDocuments];
        return;
    }
    
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithCapacity:4];

    NSFileManager *df = [NSFileManager defaultManager];
    
    BOOL fileExists = [df isReadableFileAtPath:file.path];

    NSString *fileField;
    
    DocumentRoot *document = nil;
    
    if ([file isKindOfClass: [CommentAudio class]])
    {
        CommentAudio *audio = (CommentAudio *) file;
        
        document = (DocumentRoot *)audio.document;
        
        [jsonDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:document.uid, kFieldDocument,
                            nil] 
                     forKey:kFieldParent];

        fileField = kFieldAudio;
        
    }
    else if ([file isKindOfClass: [AttachmentPagePainting class]])
    {
        AttachmentPage *page = ((AttachmentPagePainting *) file).page;
        
        document = (DocumentRoot *)page.attachment.document;
        
        [jsonDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:document.uid, kFieldDocument,
                                                                       page.attachment.uid, kFieldFile,
                                                                       page.number,kFieldPage, nil] 
                     forKey:kFieldParent];
        
        fileField = kFieldDrawing;
    }
    else
    {
        AZZLog(@"Unknown file to sync: %@", [file class]);
        self.hasError = YES;
        return;
    }

    [jsonDict setObject:document.docVersion forKey:kFieldDocVersion];

    NSObject *version;

    if (file.version)
        version = file.version;
    else 
        version = [NSNull null];
    
    [jsonDict setObject:version
                 forKey:fileField];

    __block LNDocumentWriter *blockSelf = self;
    
    [self jsonPostRequestWithUrl:self.postFileUrl
                        postData:[NSDictionary dictionaryWithObjectsAndKeys:jsonDict, kPostDataField, nil]
                           files:[NSDictionary dictionaryWithObjectsAndKeys:file.path, self.postFileField, nil] 
                      andHandler:^(NSError *err, id response)
     {
         [blockSelf->resourcesToSync removeLastObject];
         
         FileField *nextFile = [resourcesToSync lastObject];
         
         if (err)
         {
             if (isAppError(err, ERROR_IPAPKA_CONFLICT))
             {
                 [blockSelf discardDocument:document];
             }
             [blockSelf syncFile:nextFile];
             return;
         }
         
         NSString *fileField;
         
         if ([file isKindOfClass: [CommentAudio class]])
             fileField = kFieldAudio;
         else if ([file isKindOfClass: [AttachmentPagePainting class]])
             fileField = kFieldDrawing;
         else
         {
             AZZLog(@"Unknown file type: %@", [file class]);
             blockSelf.hasError = YES;
             return;
         }
         
         NSString *fileVersion = [response valueForKey:fileField];
         
         NSString *docVersion = [response valueForKey:kFieldDocVersion];
         
         if (docVersion == nil || (fileExists && fileVersion == nil))
         {
             AZZLog(@"error parsing response (docVersion or fileVersion is null): %@", response);
             blockSelf.hasError = YES;
             return;
         }
         file.version = [fileVersion isKindOfClass:[NSNull class]]?nil:fileVersion;
         file.syncStatusValue = SyncStatusSynced;
         document.docVersion = docVersion;
         [[DataSource sharedDataSource] commit];
         
         [blockSelf syncFile:nextFile];
     }];  
}

- (NSString *)postFileUrl
{
    if (!postFileUrl)
    {
        postFileUrl = [self.serverUrl stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:@"serverUploadUrl"]];
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

- (void) discardDocument:(DocumentRoot *) document
{
    
}

- (void) syncDocuments
{
    NSError *error = nil;
    
    if (![unsyncedDocuments performFetch:&error])
        NSAssert1(error == nil, @"Unhandled error executing unsynced documents: %@", [error localizedDescription]);
    
    for (DocumentRoot *document in [unsyncedDocuments fetchedObjects])
        [self syncDocument:document];
}
@end
