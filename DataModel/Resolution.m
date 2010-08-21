//
//  Resolution.m
//  DataModel
//
//  Created by Vladimir Solomenchuk on 13.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Resolution.h"


@implementation Resolution
@synthesize text, performers, managed, parentResolution;

- (void) dealloc
{
    self.text = nil;
    self.performers = nil;
    self.parentResolution = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        self.text = [coder decodeObjectForKey:@"text"];
        self.managed = [[coder decodeObjectForKey:@"managed"] boolValue];
        self.performers = [coder decodeObjectForKey:@"performers"];
        self.parentResolution = [coder decodeObjectForKey:@"parentResolution"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject: self.text forKey:@"text"];
    [coder encodeObject: self.performers forKey:@"performers"];
    [coder encodeObject: [NSNumber numberWithBool:self.managed] forKey:@"managed"];
    [coder encodeObject: parentResolution forKey:@"parentResolution"];
}
@end
