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
    ASINetworkQueue *queue;
    BOOL isSyncing;
    BOOL allRequestsSent;
    BOOL hasError;
}

@property (nonatomic, readonly) BOOL isSyncing;
@property (nonatomic, readonly) NSString *serverUrl;
@property (nonatomic, readonly) ASINetworkQueue *queue;
@property (nonatomic, assign) BOOL allRequestsSent;
@property (nonatomic, assign) BOOL hasError;

-(LNHttpRequest *) requestWithUrl:(NSString *) url;
@end
