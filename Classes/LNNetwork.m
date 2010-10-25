//
//  LNNetwork.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNNetwork.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "PasswordManager.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "LNFormDataRequest.h"

static NSString* OperationCount = @"OperationCount";

@interface LNNetwork (Private)
-(void) checkSyncing;
-(LNHttpRequest *) requestWithUrl:(NSString *) url;
-(LNFormDataRequest *) formRequestWithUrl:(NSString *) url;
@end

@implementation LNNetwork
@synthesize isSyncing, queue, allRequestsSent, hasError;

-(NSString *) serverUrl
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSString *serverUrl = [currentDefaults objectForKey:@"serverUrl"];
    return serverUrl;
}


-(void) allRequestsSent:(BOOL) value
{
    allRequestsSent = value;
    BOOL x = !allRequestsSent || (queue.requestsCount != 0);
    if ( x != isSyncing )
    {
        [self willChangeValueForKey:@"isSyncing"];
        isSyncing = x;
        [self didChangeValueForKey:@"isSyncing"];
    }
}

- (id)init 
{
    if ((self = [super init])) 
    {
        queue = [[ASINetworkQueue alloc] init];
        [queue setRequestDidFinishSelector:@selector(fetchComplete:)];
        [queue setRequestDidFailSelector:@selector(fetchFailed:)];
        
        [queue addObserver:self
                forKeyPath:@"requestsCount"
                   options:0
                   context:&OperationCount];
        
        [queue setDelegate:self];
        queue.maxConcurrentOperationCount = 1;
        [queue setShouldCancelAllRequestsOnFailure:NO];
        [queue go];
    }
    return self;
}

-(void) jsonRequestWithUrl:(NSString *)url 
                andHandler:(void (^)(BOOL error, id response)) handler
{
    LNHttpRequest *request = [self requestWithUrl:url];
    
    __block LNNetwork *blockSelf = self;
    requestComplete = NO;
    
    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *error = [request error] == nil?
        ([request responseStatusCode] == 200?
         nil:
         [NSString stringWithFormat:@"Bad response: %d", [request responseStatusCode]]):
        [[request error] localizedDescription];
        if (error)
        {
            blockSelf.hasError = YES;
            NSLog(@"error fetching url %@\n%@\n%@", [request originalURL], error, [request responseString]);
            handler(YES, nil);
        }
        else
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSError *error = nil;
            NSString *jsonString = [request responseString];
            NSDictionary *parsedResponse = [json objectWithString:jsonString error:&error];
            [json release];
            if (parsedResponse == nil)
            {
                blockSelf.hasError = YES;
                NSLog(@"error parsing response, error:%@ response: %@", error, jsonString);
                handler(NO, nil);
                return;
            }

            handler(NO, parsedResponse);
        }
    };
    
    [queue addOperation:request];
}

-(void) jsonPostRequestWithUrl:(NSString *)url 
                      postData:(NSDictionary *) postData 
                         files:(NSDictionary *) files 
                    andHandler:(void (^)(BOOL error, id response)) handler
{
    LNFormDataRequest *request = [self formRequestWithUrl:url];;
    
    SBJsonWriter *jsonWriter = [[[SBJsonWriter alloc] init] autorelease];

    NSError *error = nil;

    
    for (NSString *fieldName in [postData keyEnumerator])
    {
        id data = [postData valueForKey: fieldName];

        NSString *jsonString = [jsonWriter stringWithObject:data error: &error];
        if (error)
        {
            NSString *err  = @"Unable to create json string";
            NSLog(@"%@", err);
            return;
        }

        [request setPostValue:jsonString forKey:fieldName];
    }
    
    NSFileManager *df = [NSFileManager defaultManager];
    
    for (NSString *fieldName in [files keyEnumerator])
    {
        NSString *filePath = [files valueForKey:fieldName];
        
        if ([df isReadableFileAtPath:filePath])
            [request setFile:filePath forKey:fieldName];
    }

    
    __block LNNetwork *blockSelf = self;
    
    request.requestHandler = ^(ASIHTTPRequest *request) {
        
        NSString *error = [request error] == nil?
        ([request responseStatusCode] == 200?
         nil:
         [NSString stringWithFormat:@"Bad response: %d", [request responseStatusCode]]):
        [[request error] localizedDescription];
        if (error)
        {
            blockSelf.hasError = YES;
            NSLog(@"error fetching url %@\n%@\n%@", [request originalURL], error, [request responseString]);
            handler(YES, nil);
        }
        else
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSError *error = nil;
            NSString *jsonString = [request responseString];
            NSDictionary *parsedResponse = [json objectWithString:jsonString error:&error];
            [json release];
            if (parsedResponse == nil)
            {
                blockSelf.hasError = YES;
                NSLog(@"error parsing response, error:%@ response: %@", error, jsonString);
                handler(NO, nil);
                return;
            }
            
            handler(NO, parsedResponse);
        }
    };
    
    [queue addOperation:request];      
}



-(void) beginSession
{
    self.allRequestsSent = NO;
    self.hasError = NO;
}

-(void) endSession
{
    self.allRequestsSent = YES;
}


- (void)fetchComplete:(ASIHTTPRequest *)request
{
    void (^handler)(ASIHTTPRequest *request) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler(request);
    
    requestComplete = YES;
    [self checkSyncing];
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
    void (^handler)(ASIHTTPRequest *request) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler(request);
    
    requestComplete = YES;
    [self checkSyncing];
}

- (void)authenticationNeededForRequest:(ASIHTTPRequest *)request
{
    [[PasswordManager sharedPasswordManager] credentials:(request.authenticationRetryCount>0) handler:^(NSString *aLogin, NSString *aPassword, BOOL canceled){
        if (canceled) 
            [request cancelAuthentication];
        else
        {
            if ([request authenticationNeeded] == ASIHTTPAuthenticationNeeded) 
            {
                [request setUsername:aLogin];
                [request setPassword:aPassword];
                [request retryUsingSuppliedCredentials];
            } else if ([request authenticationNeeded] == ASIProxyAuthenticationNeeded) 
            {
                [request setProxyUsername:aLogin];
                [request setProxyPassword:aPassword];
                [request retryUsingSuppliedCredentials];
            }
        }
    }];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &OperationCount)
    {
		[self checkSyncing];
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc 
{
    [queue removeObserver:self forKeyPath:OperationCount];
    [queue reset];
	queue = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Private

-(void) checkSyncing
{
    BOOL x = !(requestComplete && allRequestsSent && (queue.requestsCount == 0));
    if ( x != isSyncing )
    {
        [self willChangeValueForKey:@"isSyncing"];
        isSyncing = x;
        [self didChangeValueForKey:@"isSyncing"];
    }
}

-(LNHttpRequest *) requestWithUrl:(NSString *) url
{
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString: url]];
    request.delegate = self;
    return request;
}

-(LNFormDataRequest *) formRequestWithUrl:(NSString *) url
{
    LNFormDataRequest *request = [LNFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.delegate = self;
    return request;
}
@end
