//
//  Comment.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Comment.h"


@implementation Comment
@synthesize author, date, text;
- (void) dealloc
{
    self.author = nil;
    self.date = nil;
    self.text = nil;
    [super dealloc];
}
@end
