//
//  Attachment.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Attachment.h"


@implementation Attachment
@synthesize title, pages, isLoaded, hasError, path;

- (void) dealloc
{
    self.title = nil;
    self.pages = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.title = [coder decodeObjectForKey:@"title"];
        self.pages = [coder decodeObjectForKey:@"pages"];
        self.path = [coder decodeObjectForKey:@"path"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.title forKey:@"title"];
    [coder encodeObject: self.pages forKey:@"pages"];
    [coder encodeObject: self.path forKey:@"path"];
}

-(UIImage *) imageForIndex:(NSUInteger) pageIndex
{
    return [UIImage imageWithContentsOfFile:[pages objectAtIndex:pageIndex]];
}
@end
