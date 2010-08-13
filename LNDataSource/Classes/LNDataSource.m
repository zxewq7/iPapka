//
//  LNDataSource.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDataSource.h"
#import "Document.h"
#import "Attachment.h"
#import "SynthesizeSingleton.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "ASINetworkQueue.h"
#import "LotusViewParser.h"

static NSString *field_Uid = @"UNID";
static NSString *field_Title = @"Title";

@interface LNDataSource(Private)
- (void)fetchComplete:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)parseViewData:(NSString *) xmlFile;
@end

@implementation LNDataSource
SYNTHESIZE_SINGLETON_FOR_CLASS(LNDataSource);
@synthesize documentsListRefreshError, documents=_documents;
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
        
        self.documents = [NSMutableDictionary dictionary];
        for(int i=0;i<100;i++)
        {
            Document *document = [[Document alloc] init];
            document.icon =  [UIImage imageNamed: @"Signature.png"];
            document.title = [NSString stringWithFormat:@"Document #%d", i];
            document.uid = [NSString stringWithFormat:@"document #%d", i];
            
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
    }
    return self;
}

-(void)dealloc
{
    [_networkQueue reset];
	[_networkQueue release];
	self.documents = nil;
    
    [super dealloc];
}

-(void) refreshDocuments
{
    LNHttpRequest *request;
    NSString *url = @"http://vovasty/~vovasty/89FB7FB8A9330311C325777C004EEFC8/89FB7FB8A9330311C325777C004EEFC8?ReadViewEntries&count=100";
	request = [LNHttpRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *folder = [[_docDirectory stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"89FB7FB8A9330311C325777C004EEFC8"];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:TRUE 
                   attributes:nil error:nil]; 
	[request setDownloadDestinationPath:[folder stringByAppendingPathComponent:@"/89FB7FB8A9330311C325777C004EEFC8.xml"]];
    request.requestHandler = ^(NSString *file, NSString* error) {
        if (error==nil)
            [self parseViewData:file];
        else
        {
            documentsListRefreshError = error;
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
    NSMutableSet *allUids = [[NSMutableSet alloc] initWithCapacity:size];
    NSMutableArray *uidsToRemove = [[NSMutableArray alloc] initWithCapacity:size];
    for (NSDictionary *entry in parser.documentEntries) 
    {
        NSString *uid = [entry objectForKey:field_Uid];
        Document *document = [self.documents objectForKey:uid];
        [allUids addObject:uid];
        if (document == nil)
        {
#warning set all fields
            document = [[Document alloc] init];
            document.icon =  [UIImage imageNamed: @"Signature.png"];
            document.title = [entry objectForKey:field_Title];
            document.uid = uid;
            [newDocuments setObject:document forKey:uid];
            [document release];
        }
    }
    
        //remove obsoleted documents
    for (NSString *uid in [self.documents allKeys])
    {
        if (![allUids containsObject:uid])
            [uidsToRemove addObject:uid];
    }
    
    if ([uidsToRemove count] >0)
    {
        NSArray *removedDocuments = [self.documents objectsForKeys:uidsToRemove notFoundMarker:@""];
        [self.documents removeObjectsForKeys:uidsToRemove];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsRemoved" object:removedDocuments];
    }
    if ([newDocuments count] >0)
    {
        [self.documents addEntriesFromDictionary:newDocuments];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsAdded" object:[newDocuments allValues]];
    }
    [uidsToRemove release];
    [allUids release];
    [newDocuments release];
}
@end
