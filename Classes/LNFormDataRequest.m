//
//  LNFormDataRequest.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNFormDataRequest.h"


@implementation LNFormDataRequest
@synthesize requestHandler;
- (void)dealloc
{
    self.requestHandler = nil;
    [super dealloc];
}
@end
