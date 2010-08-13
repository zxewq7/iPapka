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
#import "SynthesizeSingleton.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "ASINetworkQueue.h"
#import "LotusViewParser.h"

static NSString *field_Uid         = @"UNID";
static NSString *field_Title       = @"Title";
static NSString *field_Author      = @"Author";
static NSString *field_Modified    = @"Modified";
static NSString *field_Form        = @"Form";

static NSString *form_Resolution   = @"Resolution";
static NSString *form_Signature    = @"Signature";
#warning debug data
    //static NSString *url_FetchView     = @"%@/%@/%@?ReadViewEntries&count=100";
static NSString *url_FetchView     = @"%@/%@/%@.xml?ReadViewEntries&count=100";
static NSString *url_FetchDocument = @"%@/%@/%@/%@?EditDocument";

@interface LNDataSource(Private)
- (void)fetchComplete:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)parseViewData:(NSString *) xmlFile;
- (void)fetchDocument:(Document *) document;
- (void)parseDocumentData:(Document *) document xmlFile:(NSString *) xmlFile;
@end

@implementation LNDataSource
SYNTHESIZE_SINGLETON_FOR_CLASS(LNDataSource);
@synthesize documentsListRefreshError, documents=_documents, viewReplicaId, databaseReplicaId, host;
-(id)init
{
    if ((self = [super init])) {
        _networkQueue = [[ASINetworkQueue alloc] init];
        [_networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
        [_networkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
        [_networkQueue setDelegate:self];
        [_networkQueue go];
        
        NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _docDirectory = [arrayPaths objectAtIndex:0];
        [_docDirectory retain];
        
        self.documents = [NSMutableDictionary dictionary];
        
            //test data
        for(int i=0;i<100;i++)
        {
            Document *document = [[Document alloc] init];
            document.title = [NSString stringWithFormat:@"Document #%d", i];
            document.uid = [NSString stringWithFormat:@"document #%d", i];
            document.loaded  =YES;
            
            NSMutableArray *attachments = [[NSMutableArray alloc] init];
            for (int ii=0;ii<10;ii++)
            {
                Attachment *attachment = [[Attachment alloc] init];
                attachment.title = [NSString stringWithFormat:@"Attachment #%d", ii];
                [attachments addObject:attachment];
                [attachment release];
            }
            document.attachments = attachments;
            [attachments release];
            [self.documents setObject:document forKey:document.uid];
            [document release];
        }
        
        self.host = @"http://vovasty/~vovasty";
        self.databaseReplicaId = @"B87EF6328229743EC325777C004FF99C";
        self.viewReplicaId = @"89FB7FB8A9330311C325777C004EEFC8";
    }
    return self;
}

-(void)dealloc
{
    [_networkQueue reset];
	[_networkQueue release];
    [_docDirectory release];
	self.documents = nil;
    
    [super dealloc];
}

-(void) refreshDocuments
{
    LNHttpRequest *request;
    NSString *url = [NSString stringWithFormat:url_FetchView, self.host, self.databaseReplicaId, self.viewReplicaId];
    NSLog(@"start fetching %@", url);
	request = [LNHttpRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *folder = [[_docDirectory stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.databaseReplicaId];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:TRUE 
                   attributes:nil error:nil]; 
	[request setDownloadDestinationPath:[folder stringByAppendingPathComponent:self.viewReplicaId]];
    request.requestHandler = ^(NSString *file, NSString* error) {
        if (error == nil  && [request responseStatusCode] == 200)
            [self parseViewData:file];
        else
        {
            documentsListRefreshError = error;
            NSLog(@"error fetching url %@\n%@", url, error);
        }
    };
	[_networkQueue addOperation:request];
}

@end

@implementation LNDataSource(Private)
#pragma mark -
#pragma mark ASINetworkQueue delegate
- (void)fetchComplete:(ASIHTTPRequest *)request
{
    void (^handler)(NSString *file, NSString* error) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler([request downloadDestinationPath], nil);
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
    void (^handler)(NSString *file, NSString* error) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler(nil, [[request error] localizedDescription]);
}

- (void)parseViewData:(NSString *) xmlFile
{
    LotusViewParser *parser = [LotusViewParser parseView:xmlFile];
    NSUInteger size = [parser.documentEntries count];
    NSMutableDictionary *newDocuments = [[NSMutableDictionary alloc] initWithCapacity:size];
    NSMutableDictionary *updatedDocuments = [[NSMutableDictionary alloc] initWithCapacity:size];
    NSMutableSet *allUids = [[NSMutableSet alloc] initWithCapacity:size];
    NSMutableArray *uidsToRemove = [[NSMutableArray alloc] initWithCapacity:size];
    for (NSDictionary *entry in parser.documentEntries) 
    {
        NSString *uid = [entry objectForKey:field_Uid];
        Document *document = [self.documents objectForKey:uid];
        [allUids addObject:uid];
            //new document
        if (document == nil)
        {
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
            [newDocuments setObject:document forKey:uid];
            [document release];
        }
        else
        {
            NSDate *newDate = [entry objectForKey:field_Modified];
                //document updated
            if ([document.dateModified compare: newDate] == NSOrderedAscending)
            {
                document.title = [entry objectForKey:field_Title];
                document.author = [entry objectForKey:field_Author];
                document.dateModified = newDate;
                [updatedDocuments setObject:document forKey:document.uid];
            }
        }
    }
    
        //remove obsoleted documents
    for (NSString *uid in [self.documents allKeys])
    {
        if (![allUids containsObject:uid])
            [uidsToRemove addObject:uid];
    }
        //remove documents
    if ([uidsToRemove count])
    {
        NSArray *removedDocuments = [self.documents objectsForKeys:uidsToRemove notFoundMarker:@""];
        [self.documents removeObjectsForKeys:uidsToRemove];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsRemoved" object:removedDocuments];
    }
        //add new dowuments
    if ([newDocuments count])
    {
        [self.documents addEntriesFromDictionary:newDocuments];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsAdded" object:[newDocuments allValues]];
    }

        //update documents
    if ([updatedDocuments count])
    {
        [self.documents addEntriesFromDictionary:updatedDocuments];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsUpdated" object:[updatedDocuments allValues]];
    }
        //fetch new documents
    for (Document *document in [newDocuments allValues])
        [self fetchDocument: document];

        //refetch updated documents
    for (Document *document in [updatedDocuments allValues])
        [self fetchDocument: document];

    [uidsToRemove release];
    [allUids release];
    [newDocuments release];
    [updatedDocuments release];
}

- (void)fetchDocument:(Document *) document
{
    LNHttpRequest *request;
    NSString *url = [NSString stringWithFormat:url_FetchDocument, self.host, self.databaseReplicaId, self.viewReplicaId, document.uid];
    NSLog(@"start fetching %@", url);
	request = [LNHttpRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *folder = [[[_docDirectory stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.databaseReplicaId] stringByAppendingPathComponent:document.uid];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:TRUE 
                                               attributes:nil error:nil]; 
	[request setDownloadDestinationPath:[folder stringByAppendingPathComponent:@"index.html"]];
    request.requestHandler = ^(NSString *file, NSString* error) {
        if (error == nil && [request responseStatusCode] == 200)
        {
            [self parseDocumentData:document xmlFile:file];
        }
        else
        {
            document.hasError = YES;
            NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", url, error, [request responseStatusCode]);
        }
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsUpdated" object:[NSArray arrayWithObject:document]];
    };
	[_networkQueue addOperation:request];
}
- (void)parseDocumentData:(Document *) document xmlFile:(NSString *) xmlFile;
{
    document.hasError = NO;
    document.loaded = YES;
}
@end
