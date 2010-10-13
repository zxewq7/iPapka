//
//  LNPersonReader.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 13.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNPersonReader.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "PasswordManager.h"
#import "SBJsonParser.h"
#import "Person.h"

static NSString* OperationCount = @"OperationCount";

static NSString* kFieldUid = @"id";
static NSString* kFieldFirst = @"first";
static NSString* kFieldLast = @"last";
static NSString* kFieldMiddle = @"middle";

@implementation LNPersonReader
@synthesize dataSource, isSyncing;

- (id) initWithUrl:(NSString *) anUrl
{
    if ((self = [super init])) {
        
        url = [anUrl stringByAppendingString:@"/getExecutors?OpenAgent"];
        
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
- (void) sync;
{
    allRequestsSent = NO;
    
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString: url]];
    request.delegate = self;
    
    id<LNPersonReaderDataSource> mds = [self dataSource];

    __block LNPersonReader *blockSelf = self;

    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *error = [request error] == nil?
        ([request responseStatusCode] == 200?
         nil:
         NSLocalizedString(@"Bad response", "Bad response")):
        [[request error] localizedDescription];
        if (error)
            NSLog(@"error fetching url %@\n%@", [request originalURL], error);
        else
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSError *error = nil;
            NSString *jsonString = [request responseString];
            NSArray *parsedResponse = [json objectWithString:jsonString error:&error];
            [json release];
            if (parsedResponse == nil)
            {
                NSLog(@"error parsing response, error:%@ response: %@", error, jsonString);
                return;
            }
            
            NSMutableSet *allUids = [NSMutableSet setWithCapacity:[parsedResponse count]];
            
            for (NSDictionary *personDict in parsedResponse)
            {
                NSString *uid = [personDict objectForKey:kFieldUid];
                NSString *first = [personDict objectForKey:kFieldFirst];
                NSString *last = [personDict objectForKey:kFieldLast];
                NSString *middle = [personDict objectForKey:kFieldMiddle];
                
                if (!(uid && first && last))
                {
                    NSLog(@"not enough person attributes, skipped %@", personDict);
                    continue;
                }
                
                Person *person = [mds personReader:blockSelf personWithUid:uid];
                if (!person)
                    person = [[blockSelf dataSource] personReaderCreatePerson:blockSelf];
                person.uid = uid;
                person.first = first;
                person.last = last;
                person.middle = middle;
                
                [allUids addObject: uid];
            }

            NSSet *currentUids = [mds personReaderAllPersonsUids:blockSelf];
            
            for (NSString *uid in currentUids)
            {
                if (![allUids containsObject: uid])
                {
                    Person *person = [mds personReader:blockSelf personWithUid:uid];
                    if (person)
                        [mds personReader:blockSelf removeObject:person];
                }
            }
            
            [mds personReaderCommit:blockSelf];
        }
        
    };
    [queue addOperation:request];
    allRequestsSent = YES;
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
	[queue release]; queue = nil;
    [dataSource release];
    
    [super dealloc];
}
@end
