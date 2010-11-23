//
//  LNNetwork.m
//  iPapka
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
static NSString* kErrorCode = @"code";

@interface LNNetwork (Private)
-(void) checkSyncing;
-(LNHttpRequest *) requestWithUrl:(NSString *) url;
-(LNFormDataRequest *) formRequestWithUrl:(NSString *) url;
- (NSError *)errorFromRequest:(ASIHTTPRequest *) request;
-(void) beginRequest;
-(void) endRequest;
-(void) beginSession;
-(void) endSession;
@end

@implementation LNNetwork
@synthesize isSyncing, queue, hasError, numberOfRequests;

-(NSString *) serverUrl
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSString *serverUrl = [currentDefaults objectForKey:@"serverUrl"];
    return serverUrl;
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

-(void) sync
{
    [self beginSession];
    [self run];
    [self endSession];
}

-(void) run
{
    NSAssert(NO, @"run method MUST be replaced");
}

-(void) fileRequestWithUrl:(NSString *)url 
                      path:(NSString *)path 
                andHandler:(void (^)(NSError *error, NSString* path)) handler
{
    NSFileManager *df = [NSFileManager defaultManager];
    
    [df createDirectoryAtPath:[path stringByDeletingLastPathComponent] 
  withIntermediateDirectories:TRUE 
                   attributes:nil 
                        error:nil];

    LNHttpRequest *request = [self requestWithUrl:url];

    [request setDownloadDestinationPath:path];

    __block LNNetwork *blockSelf = self;

    [self beginRequest];

    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSError *err = [blockSelf errorFromRequest:request];
        if (err)
        {
            blockSelf.hasError = YES;
            [df removeItemAtPath:path error:NULL];
            handler(err, nil);
        }
        else
            handler(nil, path);
    };
    
    [queue addOperation:request];
}

-(void) jsonRequestWithUrl:(NSString *)url 
                andHandler:(void (^)(NSError *error, id response)) handler
{
    LNHttpRequest *request = [self requestWithUrl:url];
    
    __block LNNetwork *blockSelf = self;

    [self beginRequest];
    
    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSError *err = [blockSelf errorFromRequest:request];
        
        if (err)
        {
            blockSelf.hasError = YES;
            handler(err, nil);
        }
        else
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSError *error = nil;
            NSString *jsonString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
            NSDictionary *parsedResponse = [json objectWithString:jsonString error:&error];
            [json release];
            [jsonString release];
            if (parsedResponse == nil)
            {
                blockSelf.hasError = YES;
                AZZLog(@"error fetching url: %@\n error:%@\n response:%@", [request originalURL], error, [request responseString]);
                handler(NSErrorWithCode(ERROR_IPAPKA_SERVER), nil);
                return;
            }

            handler(nil, parsedResponse);
        }
    };
    
    [queue addOperation:request];
}

-(void) jsonPostRequestWithUrl:(NSString *)url 
                      postData:(NSDictionary *) postData 
                         files:(NSDictionary *) files 
                    andHandler:(void (^)(NSError *error, id response)) handler
{
    LNFormDataRequest *request = [self formRequestWithUrl:url];
    
    request.postFormat = ASIMultipartFormDataPostFormat;
    request.stringEncoding = NSUTF8StringEncoding;
    
    SBJsonWriter *jsonWriter = [[[SBJsonWriter alloc] init] autorelease];

    NSError *error = nil;

    
    for (NSString *fieldName in [postData keyEnumerator])
    {
        id data = [postData valueForKey: fieldName];

        NSString *jsonString = [jsonWriter stringWithObject:data error: &error];
        if (error)
        {
            NSString *err  = @"Unable to create json string";
            AZZLog(@"%@", err);
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
    
    [self beginRequest];
    
    request.requestHandler = ^(ASIHTTPRequest *request) 
    {
        NSError *err = [blockSelf errorFromRequest:request];
        
        if (err)
        {
            blockSelf.hasError = YES;
            handler(err, nil);
        }
        else
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSError *error = nil;
            NSString *jsonString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
            NSDictionary *parsedResponse = [json objectWithString:jsonString error:&error];
            [json release];
            [jsonString release];
            
            if (parsedResponse == nil)
            {
                blockSelf.hasError = YES;
                AZZLog(@"error fetching url: %@\n error:%@\n response:%@", [request originalURL], error, [request responseString]);
                handler(NSErrorWithCode(ERROR_IPAPKA_SERVER), nil);
                return;
            }
            
            handler(nil, parsedResponse);
        }
    };
    
    [queue addOperation:request];      
}



-(void) beginSession
{
    self.hasError = NO;

    [self willChangeValueForKey:@"isSyncing"];
    isSyncing = YES;
    [self didChangeValueForKey:@"isSyncing"];

    self.numberOfRequests = 0;
}

-(void) endSession
{
    [self checkSyncing];
}


- (void)fetchComplete:(ASIHTTPRequest *)request
{
    void (^handler)(ASIHTTPRequest *request) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler(request);
    
    [self endRequest];
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
    void (^handler)(ASIHTTPRequest *request) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler(request);
    
    [self endRequest];
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
    BOOL x = !(self.numberOfRequests == 0 && queue.requestsCount == 0);
    
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
    request.validatesSecureCertificate = [[NSUserDefaults standardUserDefaults] boolForKey:@"serverValidateSecureCertificate"];
    request.numberOfTimesToRetryOnTimeout = 1;
    return request;
}

-(LNFormDataRequest *) formRequestWithUrl:(NSString *) url
{
    LNFormDataRequest *request = [LNFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.delegate = self;
    request.validatesSecureCertificate = [[NSUserDefaults standardUserDefaults] boolForKey:@"serverValidateSecureCertificate"];
    request.numberOfTimesToRetryOnTimeout = 1;
    return request;
}

-(void) beginRequest
{
    self.numberOfRequests++;
}

-(void) endRequest
{
    self.numberOfRequests--;
    
    [self checkSyncing];
}

- (NSError *)errorFromRequest:(ASIHTTPRequest *) request
{
    SBJsonParser *json;
    
    if ([request error])
    {
        AZZLog(@"error fetching url: %@\nerror:%@", [request originalURL], [request error]);
        return NSErrorWithCode(ERROR_IPAPKA_SERVER);
    }
    else 
    {
        switch ([request responseStatusCode]) 
        {
            case 500:
                AZZLog(@"error fetching url: %@\ncode:%d\nresponse:%@", [request originalURL], [request responseStatusCode], [request responseString]);
                json = [[SBJsonParser alloc] init];
                NSString *jsonString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
                NSDictionary *parsedResponse = [json objectWithString:jsonString error:nil];
                [json release];
                [jsonString release];
                NSNumber *errorCode = [parsedResponse objectForKey:kErrorCode];
                if (errorCode)
                    return NSErrorWithCode(ERROR_IPAPKA_CONFLICT);
                else
                    return NSErrorWithCode(ERROR_IPAPKA_SERVER);
            case 200:
                return nil;
            default:
                AZZLog(@"error fetching url: %@\n code:%d\n response:%@", [request originalURL], [request responseStatusCode], [request responseString]);
                return NSErrorWithCode(ERROR_IPAPKA_SERVER);
        }        
    }
}
@end
