//
//  LNDocumentSaver.h
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 22.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue, Document;

@interface LNDocumentSaver : NSObject 
{
    ASINetworkQueue *queue;
    NSString        *url;
    NSString        *login;
    NSString        *password;
    NSDateFormatter *parseFormatterSimple;
    NSString        *requestUrl;
}

- (id) initWithUrl:(NSString *) anUrl;

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *password;

- (void) sendDocument:(Document *) document handler:(void(^)(LNDocumentSaver *sender, NSString *error)) handler;
@end
