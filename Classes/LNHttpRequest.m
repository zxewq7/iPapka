//
//  LNHttpRequest.m
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 13.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LNHttpRequest.h"


@implementation LNHttpRequest
@synthesize requestHandler;
- (void)dealloc
{
    self.requestHandler = nil;
    [super dealloc];
}
@end
