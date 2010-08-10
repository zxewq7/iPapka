//
//  Document.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Document.h"


@implementation Document
@synthesize uid, title, remoteUrl, icon;
- (void) dealloc
{
    self.uid = nil;
    self.title = nil;
    self.remoteUrl = nil;
    self.icon = nil;
    [super dealloc];
}
@end
