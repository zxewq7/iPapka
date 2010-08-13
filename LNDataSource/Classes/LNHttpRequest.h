//
//  LNHttpRequest.h
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 13.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface LNHttpRequest : ASIHTTPRequest {
    void (^requestHandler)(NSString *file, NSString* error);
}
@property (nonatomic, copy) void (^requestHandler)(NSString *file, NSString* error);
@end
