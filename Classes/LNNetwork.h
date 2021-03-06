//
//  LNNetwork.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 14.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppErrors.h"

@class ASINetworkQueue, LNHttpRequest;
@interface LNNetwork : NSObject 
{
@private ASINetworkQueue *queue;
@private BOOL isSyncing;
@private BOOL hasError;
@private NSUInteger numberOfRequests;
}

@property (nonatomic, readonly) BOOL isSyncing;
@property (nonatomic, readonly) NSString *serverUrl;
@property (nonatomic, readonly) ASINetworkQueue *queue;
@property (nonatomic, assign) BOOL hasError;
@property (assign) NSUInteger numberOfRequests;

-(void) jsonRequestWithUrl:(NSString *)url 
                andHandler:(void (^)(NSError *error, id response)) handler;

-(void) jsonPostRequestWithUrl:(NSString *)url 
                      postData:(NSDictionary *) postData 
                         files:(NSDictionary *) files 
                    andHandler:(void (^)(NSError *error, id response)) handler;

-(void) fileRequestWithUrl:(NSString *)url 
                      path:(NSString *)path 
                andHandler:(void (^)(NSError *error, NSString* path)) handler;

-(void) sync;
-(void) run;
-(void) stopSync;
@end
