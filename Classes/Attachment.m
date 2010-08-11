//
//  Attachment.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Attachment.h"


@implementation Attachment
@synthesize title, remoteUrl, icon;
- (void) dealloc
{
    self.title = nil;
    self.icon = nil;
    self.remoteUrl = nil;
    [super dealloc];
}
@end
