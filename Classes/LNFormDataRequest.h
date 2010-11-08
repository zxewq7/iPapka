//
//  LNFormDataRequest.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 11.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@interface LNFormDataRequest : ASIFormDataRequest 
{
    void (^requestHandler)(ASIHTTPRequest *request);
}

@property (nonatomic, copy) void (^requestHandler)(ASIHTTPRequest *request);
@end
