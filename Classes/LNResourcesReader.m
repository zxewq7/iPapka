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
#import "Attachment.h"
#import "DataSource.h"
#import "DocumentWithResources.h"
#import "DocumentRoot.h"

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

-(void) run
{
    NSError *error = nil;
    
    if (![unsyncedFiles performFetch:&error])
		NSAssert1(error == nil, @"Unhandled error executing unsynced files: %@", [error localizedDescription]);

    NSArray *objects = [unsyncedFiles fetchedObjects];
    
    for (FileField *file in objects)
        [self readFile:file];

    if (![unsyncedPages performFetch:&error])
		NSAssert1(error == nil, @"Unhandled error executing unsynced pages: %@", [error localizedDescription]);
    
    objects = [unsyncedPages fetchedObjects];
    
    for (AttachmentPage *page in objects)
        [self readPage:page];
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
    DocumentWithResources *rootDocument = attachment.document;
    
    if ([rootDocument isKindOfClass:[DocumentLink class]]) //link
    {
        DocumentLink *link = (DocumentLink *)rootDocument;
        
        rootDocument = (DocumentRoot *)link.document;
        
        url = [self.serverUrl stringByAppendingFormat:url_LinkAttachmentFetchPageFormat, rootDocument.uid, link.uid, attachment.uid, page.number];
    }
    else
        url = [self.serverUrl stringByAppendingFormat:url_AttachmentFetchPageFormat, rootDocument.uid, attachment.uid, page.number];
    
    [self fileRequestWithUrl:url
                        path:page.pathImage
                andHandler:^(NSError *err, NSString* path)
     {
         if (err)
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
                  andHandler:^(NSError *err, NSString* path)
     {
         if (err)
             blockSelf.hasError = NO;
         else
         {
             file.syncStatusValue = SyncStatusSynced;
             [[DataSource sharedDataSource] commit];
         }
     }];
}
@end
