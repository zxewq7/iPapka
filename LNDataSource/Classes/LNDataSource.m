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
            self.documentsListRefreshed = NO;
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
    for (NSDictionary *entry in parser.documentEntries) 
    {
        NSLog(@"%@", entry);
    }
    
    self.documentsListRefreshed = YES;
}
@end
