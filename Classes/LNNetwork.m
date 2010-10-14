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

static NSString* OperationCount = @"OperationCount";

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

-(LNHttpRequest *) requestWithUrl:(NSString *) url
{
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString: url]];
    request.delegate = self;
    return request;
}

-(void) jsonRequestWithUrl:(NSString *)url andHandler:(void (^)(BOOL error, NSObject *response)) handler
{
    LNHttpRequest *request = [self requestWithUrl:url];
    
    __block LNNetwork *blockSelf = self;
    
    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *error = [request error] == nil?
        ([request responseStatusCode] == 200?
         nil:
         NSLocalizedString(@"Bad response", "Bad response")):
        [[request error] localizedDescription];
        if (error)
        {
            blockSelf.hasError = YES;
            NSLog(@"error fetching url %@\n%@", [request originalURL], error);
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
		BOOL x = !allRequestsSent || (queue.requestsCount != 0);
        if ( x != isSyncing )
        {
            [self willChangeValueForKey:@"isSyncing"];
            isSyncing = x;
            [self didChangeValueForKey:@"isSyncing"];
        }
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

@end
