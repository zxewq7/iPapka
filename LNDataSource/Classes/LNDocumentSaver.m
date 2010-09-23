//
//  LNDocumentSaver.m
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 22.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDocumentSaver.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "Document.h"
#import "SBJsonWriter.h"
#import "Resolution.h"

@implementation LNDocumentSaver
@synthesize url, login, password;

- (id) initWithUrl:(NSString *) anUrl
{
    if ((self = [super init])) {
        parseFormatterSimple = [[NSDateFormatter alloc] init];
        //20100811
        [parseFormatterSimple setDateFormat:@"yyyyMMdd"];
        
        url = [anUrl retain];
        
        requestUrl = [url stringByAppendingString:@"/ipad.transfer?OpenAgent&charset=utf-8"];
        
        [requestUrl retain];
        
        queue = [[ASINetworkQueue alloc] init];
        [queue setRequestDidFinishSelector:@selector(fetchComplete:)];
        [queue setRequestDidFailSelector:@selector(fetchFailed:)];

        [queue setDelegate:self];
        [queue go];
    }
    return self;
}


- (void) sendDocument:(Document *) document handler:(void(^)(LNDocumentSaver *sender, NSString *error)) handler
{
    NSMutableDictionary *dictDocument = [[NSMutableDictionary alloc] initWithCapacity: 6];
    
    [dictDocument setObject:document.uid forKey:@"id"];
    
    NSString *action;
    
    if (document.isAccepted)
        action = @"approve";
    else if (document.isDeclined)
        action = @"reject";
    else
        action = @"save";
    
    [dictDocument setObject:action forKey:@"action"];
    
    if ([document isKindOfClass: [Resolution class]])
    {
        Resolution *resolution = (Resolution *) document;
        
        if (resolution.deadline)
            [dictDocument setObject:[parseFormatterSimple stringFromDate:resolution.deadline] forKey:@"deadline"];
        
        if (resolution.performers)
            [dictDocument setObject:resolution.performers forKey:@"performers"];
        
        if (resolution.text)
            [dictDocument setObject:resolution.text forKey:@"text"];
    }

    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    
    NSError *error = nil;
    NSString *postData = [jsonWriter stringWithObject:dictDocument error: &error];

    [dictDocument release];
    [jsonWriter release];
    
    if (error)
    {
        NSString *err  = @"Unable to create json string";
        NSLog(@"%@", err);
        if (handler)
            handler(self, err);
        return;
    }
    
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString: requestUrl]];
    
    [request addRequestHeader:@"Content-Type" value:@"text/plain; charset=utf-8"];
    
    request.username = self.login;
    request.password = self.password;
    
    request.requestMethod = @"POST";
    
    request.postBody = [[postData dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    __block LNDocumentSaver *blockSelf = self;

    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *error = [request error] == nil?
            ([request responseStatusCode] == 200?
             nil:
             NSLocalizedString(@"Bad response", "Bad response")):
            [[request error] localizedDescription];
        if (error)
            NSLog(@"error fetching url %@\n%@", [request originalURL], error);
        
        if (handler)
            handler(blockSelf, error);
    };
    
    [queue addOperation:request];
}

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
- (void)dealloc {
    [queue reset];
	[queue release];
    queue = nil;
    
    self.login = nil;
    
    self.password = nil;
    
    [parseFormatterSimple release];
    
    parseFormatterSimple = nil;
    
    [requestUrl release];
    
    requestUrl =  nil;
    
    [super dealloc];
}
@end
