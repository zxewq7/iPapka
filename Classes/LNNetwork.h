//
//  LNNetwork.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue, LNHttpRequest;
@interface LNNetwork : NSObject 
{
@private ASINetworkQueue *queue;
@private BOOL isSyncing;
@private BOOL allRequestsSent;
@private BOOL hasError;
@private BOOL requestComplete;
}

@property (nonatomic, readonly) BOOL isSyncing;
@property (nonatomic, readonly) NSString *serverUrl;
@property (nonatomic, readonly) ASINetworkQueue *queue;
@property (nonatomic, assign) BOOL allRequestsSent;
@property (nonatomic, assign) BOOL hasError;

-(void) jsonRequestWithUrl:(NSString *)url 
                andHandler:(void (^)(BOOL error, id response)) handler;

-(void) jsonPostRequestWithUrl:(NSString *)url 
                      postData:(NSDictionary *) postData 
                         files:(NSDictionary *) files 
                    andHandler:(void (^)(BOOL error, id response)) handler;

-(void) fileRequestWithUrl:(NSString *)url 
                      path:(NSString *)path 
                andHandler:(void (^)(BOOL error, NSString* path)) handler;

-(void) beginSession;
-(void) endSession;
@end
