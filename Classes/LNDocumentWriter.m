//
//  LNDocumentSaver.m
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 22.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDocumentWriter.h"
#import "Document.h"
#import "DocumentResolution.h"
#import "DocumentSignature.h"
#import "DataSource.h"
#import "Person.h"
#import "FileField.h"
#import "Comment.h"
#import "CommentAudio.h"
#import "AttachmentPagePainting.h"
#import "Attachment.h"
#import "AttachmentPage.h"

static NSString* kFieldVersion = @"version";
static NSString* kFieldUid = @"id";
static NSString* kFieldDeadline = @"deadline";
static NSString* kFieldPerformers = @"performers";
static NSString* kFieldText = @"text";
static NSString* kFieldFile = @"file";
static NSString* kPostDataField = @"json";
static NSString* kFieldParent = @"parent";
static NSString* kFieldDocument = @"document";
static NSString* kFieldPage = @"page";
static NSString* kFieldAudio = @"audio";
static NSString* kFieldDrawing = @"drawing";

@interface LNDocumentWriter(Private)
- (void) syncDocument:(Document *) document;
- (void) syncFile:(FileField *) file;
- (NSString *)postFileUrl;
- (NSString *)postFileField;
@end


@implementation LNDocumentWriter
@synthesize unsyncedDocuments, unsyncedFiles;

- (id) init
{
    if ((self = [super init])) {
        parseFormatterSimple = [[NSDateFormatter alloc] init];
        //20100811
        [parseFormatterSimple setDateFormat:@"yyyyMMdd"];
    }
    return self;
}


- (void) sync
{
    if (self.isSyncing) //prevent multiple syncs
        return;
    
    [self beginSession];
    
    NSError *error = nil;

    if (![unsyncedFiles performFetch:&error])
		NSAssert1(error == nil, @"Unhandled error executing unsynced files: %@", [error localizedDescription]);
    
    for (FileField *file in [unsyncedFiles fetchedObjects])
        [self syncFile:file];

    if (![unsyncedDocuments performFetch:&error])
		NSAssert1(error == nil, @"Unhandled error executing unsynced documents: %@", [error localizedDescription]);

    for (Document *document in [unsyncedDocuments fetchedObjects])
        [self syncDocument:document];


    [self endSession];
}

- (void)dealloc {
    [parseFormatterSimple release]; parseFormatterSimple = nil;
    
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
    
    NSString *status;
    
    switch (document.statusValue)
    {
        case DocumentStatusNew:
        case DocumentStatusDraft:
            status = @"draft";
            break;
        case DocumentStatusAccepted:
            status = @"approved";
            break;
        case DocumentStatusDeclined:
            status = @"rejected";
            break;
        default:
            NSLog(@"unknown status %d dor document %@", document.statusValue, document.uid);
            return;
    }
    
    [dictDocument setObject:status forKey:@"status"];
    
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
    else if ([document isKindOfClass: [DocumentSignature class]])
    {
        DocumentSignature *sugnature = (DocumentSignature *)document;
        if (sugnature.comment.text)
            [dictDocument setObject:sugnature.comment.text forKey:kFieldText];
    }
    
    [self jsonPostRequestWithUrl:self.postFileUrl
                        postData:[NSDictionary dictionaryWithObjectsAndKeys:dictDocument, kPostDataField, nil]
                           files:nil 
                      andHandler:^(BOOL error, id response)
    {
        if (error)
            return;
        
        document.syncStatusValue = SyncStatusSynced;
        [[DataSource sharedDataSource] commit];
    }];  
}

- (void) syncFile:(FileField *) file
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithCapacity:4];

    NSFileManager *df = [NSFileManager defaultManager];
    
    BOOL fileExists = [df isReadableFileAtPath:file.path];

    NSString *fileField;
    
    if ([file isKindOfClass: [CommentAudio class]])
    {
        CommentAudio *audio = (CommentAudio *) file;
        
        [jsonDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:audio.comment.document.uid, kFieldDocument,
                            nil] 
                     forKey:kFieldParent];

        fileField = kFieldAudio;
        
    }
    else if ([file isKindOfClass: [AttachmentPagePainting class]])
    {
        AttachmentPagePainting *painting = (AttachmentPagePainting *) file;
        
        [jsonDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:painting.page.attachment.document.uid, kFieldDocument,
                                                                       painting.page.attachment.uid, kFieldFile,
                                                                       painting.page.number,kFieldPage, nil] 
                     forKey:kFieldParent];
        
        fileField = kFieldDrawing;
    }
    else
    {
        NSLog(@"Unknown file to sync: %@", [file class]);
        return;
    }

    id fileContent;
    
    if (fileExists)
        fileContent =  [NSDictionary dictionaryWithObjectsAndKeys:file.version, kFieldVersion,
                 file.uid, kFieldUid,
                 nil];
    else
        fileContent = @"null";
    
    [jsonDict setObject:fileContent
                 forKey:fileField];

    
    [self jsonPostRequestWithUrl:self.postFileUrl
                        postData:[NSDictionary dictionaryWithObjectsAndKeys:jsonDict, kPostDataField, nil]
                           files:[NSDictionary dictionaryWithObjectsAndKeys:file.path, self.postFileField, nil] 
                      andHandler:^(BOOL error, id response)
     {
         if (error)
             return;
         
         NSString *uid = [response valueForKey:kFieldUid];
         NSString *version = [response valueForKey:kFieldVersion];
         if (uid == nil || version == nil)
         {
             NSLog(@"error parsing response: %@", response);
             return;
         }
         file.uid = uid;
         file.version = version;
         file.syncStatusValue = SyncStatusSynced;
         [[DataSource sharedDataSource] commit];
         
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
@end
