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

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.author = [coder decodeObjectForKey:@"author"];
        self.date = [coder decodeObjectForKey:@"date"];
        self.text = [coder decodeObjectForKey:@"text"];

    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.author forKey:@"author"];
    [coder encodeObject: self.date forKey:@"date"];
    [coder encodeObject: self.text forKey:@"text"];
}
@end
