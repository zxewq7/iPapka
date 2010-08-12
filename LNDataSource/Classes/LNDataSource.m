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
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@interface LNDataSource(Private)
- (void)fetchComplete:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)parseViewData:(NSString *) xmlFile;
@end

@implementation LNDataSource
SYNTHESIZE_SINGLETON_FOR_CLASS(LNDataSource);
@synthesize documentsListRefreshed, documentsListRefreshError;
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
        
        _handlers = [[NSMutableDictionary alloc] init];
        
        _documents = [[NSMutableArray alloc] init];
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
            [(NSMutableArray *)_documents addObject:document];
            [document release];
        }
    }
    return self;
}

-(void)dealloc
{
    [_networkQueue reset];
	[_networkQueue release];
	[_documents release];
    
    [super dealloc];
}

- (NSUInteger) count
{
    return [_documents count];
}

- (Document *) documentAtIndex:(NSUInteger) anIndex
{
    return [_documents objectAtIndex:anIndex];
}
-(void) refreshDocuments
{
    ASIHTTPRequest *request;
    NSString *url = @"http://vovasty/~vovasty/89FB7FB8A9330311C325777C004EEFC8/89FB7FB8A9330311C325777C004EEFC8?ReadViewEntries&count=100";
	request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *folder = [[_docDirectory stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"89FB7FB8A9330311C325777C004EEFC8"];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:TRUE 
                   attributes:nil error:nil]; 
	[request setDownloadDestinationPath:[folder stringByAppendingPathComponent:@"/89FB7FB8A9330311C325777C004EEFC8.xml"]];
    id hnd = ^(NSString *file, NSString* error) {
        if (error!=nil)
            [self parseViewData:file];
        else
            documentsListRefreshError = error;
    };
    [_handlers setObject:hnd forKey:url];
    [hnd release];
	[_networkQueue addOperation:request];
}

@end

@implementation LNDataSource(Private)
#pragma mark -
#pragma mark ASINetworkQueue delegate
- (void)fetchComplete:(ASIHTTPRequest *)request
{
    NSString *url = [[request originalURL] absoluteString];
    int (^handler)(NSString *file, NSString* error) = [_handlers objectForKey:url];
    if (handler)
        handler([request downloadDestinationPath], nil);
    [_handlers removeObjectForKey:url];
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
    NSString *url = [[request originalURL] absoluteString];
    int (^handler)(NSString *file, NSString* error) = [_handlers objectForKey:url];
    if (handler)
        handler(nil, [[request error] localizedDescription]);
    [_handlers removeObjectForKey:url];
}
- (void)parseViewData:(NSString *) xmlFile
{
    self.documentsListRefreshed = YES;
}
@end
