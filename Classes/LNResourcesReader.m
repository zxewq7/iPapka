//
//  LNResourcesReader.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 08.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "FileField.h"
#import "LNResourcesReader.h"
#import "AttachmentPage.h"
#import "DocumentLink.h"
#import "Document.h"
#import "Attachment.h"
#import "DataSource.h"

//document/id/file/file.id/page/pagenum
static NSString *url_AttachmentFetchPageFormat = @"/document/%@/file/%@/page/%@";

//document/id/link/link.id/file/file.id/page/pagenum
static NSString *url_LinkAttachmentFetchPageFormat = @"/document/%@/link/%@/file/%@/page/%@";

@interface LNResourcesReader(Private) 
-(void)readFile:(FileField *) file;
-(void)readPage:(AttachmentPage *) page;
@end

@implementation LNResourcesReader
@synthesize unsyncedFiles, unsyncedPages;

-(void) sync
{
    [self beginSession];
    
    NSError *error = nil;
    
    if (![unsyncedFiles performFetch:&error])
		NSAssert1(error == nil, @"Unhandled error executing unsynced files: %@", [error localizedDescription]);

    for (FileField *file in [unsyncedFiles fetchedObjects])
        [self readFile:file];

    if (![unsyncedPages performFetch:&error])
		NSAssert1(error == nil, @"Unhandled error executing unsynced pages: %@", [error localizedDescription]);
    
    for (AttachmentPage *page in [unsyncedPages fetchedObjects])
        [self readPage:page];

    [self endSession];
}

- (void)dealloc 
{
    self.unsyncedFiles = nil;
    
    self.unsyncedPages = nil;

    [super dealloc];
}

#pragma mark Private

-(void) readPage:(AttachmentPage *) page
{
    __block LNResourcesReader *blockSelf = self;
    
    NSString *url;
    
    Attachment *attachment = page.attachment;
    Document *rootDocument = attachment.document;
    
    if ([rootDocument isKindOfClass:[DocumentLink class]]) //link
    {
        DocumentLink *link = (DocumentLink *)rootDocument;
        
        rootDocument = link.document;
        
        url = [self.serverUrl stringByAppendingFormat:url_LinkAttachmentFetchPageFormat, rootDocument.uid, link.index, attachment.uid, page.number];
    }
    else
        url = [self.serverUrl stringByAppendingFormat:url_AttachmentFetchPageFormat, rootDocument.uid, attachment.uid, page.number];
    
    [self fileRequestWithUrl:url
                        path:page.pathImage
                andHandler:^(BOOL error, NSString* path)
     {
         if (error)
             blockSelf.hasError = NO;
         else
         {
             page.syncStatusValue = SyncStatusSynced;
             [[DataSource sharedDataSource] commit];
         }
     }];
}

- (void)readFile:(FileField *)file
{

    __block LNResourcesReader *blockSelf = self;
    
    NSString *url = [self.serverUrl stringByAppendingString:file.url];
    
    [self fileRequestWithUrl:url
                        path:file.path
                  andHandler:^(BOOL error, NSString* path)
     {
         if (error)
             blockSelf.hasError = NO;
         else
         {
             file.syncStatusValue = SyncStatusSynced;
             [[DataSource sharedDataSource] commit];
         }
     }];
}
@end
