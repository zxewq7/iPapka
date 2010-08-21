//
//  Document.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Document.h"


@implementation Document
@synthesize uid, title, author, date, attachments, dateModified, isLoaded, hasError, isRead;
- (void) dealloc
{
    self.title = nil;
    self.author = nil;
    self.date = nil;
    self.attachments = nil;
    self.uid = nil;
    self.dateModified = nil;
    self.isRead = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.title = [coder decodeObjectForKey:@"title"];
        self.author = [coder decodeObjectForKey:@"author"];
        self.date = [coder decodeObjectForKey:@"date"];
        self.attachments = [coder decodeObjectForKey:@"attachments"];
        self.uid = [coder decodeObjectForKey:@"uid"];
        self.dateModified = [coder decodeObjectForKey:@"dateModified"];
        self.isRead = [coder decodeObjectForKey:@"isRead"];

    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.title forKey:@"title"];
    [coder encodeObject: self.author forKey:@"author"];
    [coder encodeObject: self.date forKey:@"date"];
    [coder encodeObject: self.attachments forKey:@"attachments"];
    [coder encodeObject: self.uid forKey:@"uid"];
    [coder encodeObject: self.dateModified forKey:@"dateModified"];
    [coder encodeObject: self.isRead forKey:@"isRead"];
}

#pragma mark -
#pragma mark isEqual implementation

- (NSUInteger)hash;
{
	return [self.uid hash];
}

- (BOOL)isEqual:(id)anObject
{
	if ([anObject isKindOfClass: [Document class]])
		return [[anObject uid] isEqualToString: uid];
	else
		return NO;
}

@end
