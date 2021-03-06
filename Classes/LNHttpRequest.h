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
    void (^requestHandler)(ASIHTTPRequest *request);
}
@property (nonatomic, copy) void (^requestHandler)(ASIHTTPRequest *request);
@end
