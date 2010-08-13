//
//  Document.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Document.h"


@implementation Document
@synthesize uid, title, remoteUrl, author, date, comments, attachments, dateModified, loaded, hasError;
- (void) dealloc
{
    self.title = nil;
    self.author = nil;
    self.date = nil;
    self.comments = nil;
    self.attachments = nil;
    self.remoteUrl = nil;
    self.uid = nil;
    self.dateModified = nil;
    [super dealloc];
}

@dynamic icon;
- (UIImage *) icon
{
    return [UIImage imageNamed: hasError?@"SignatureError.png":loaded?@"Signature.png":@"SignatureNotLoaded.png"];
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

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.title = [coder decodeObjectForKey:@"title"];
        self.author = [coder decodeObjectForKey:@"author"];
        self.date = [coder decodeObjectForKey:@"date"];
        self.comments = [coder decodeObjectForKey:@"comments"];
        self.attachments = [coder decodeObjectForKey:@"attachments"];
        self.remoteUrl = [coder decodeObjectForKey:@"remoteUrl"];
        self.uid = [coder decodeObjectForKey:@"uid"];
        self.dateModified = [coder decodeObjectForKey:@"dateModified"];
        self.loaded = [[coder decodeObjectForKey:@"loaded"] boolValue];

    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.title forKey:@"title"];
    [coder encodeObject: self.author forKey:@"author"];
    [coder encodeObject: self.date forKey:@"date"];
    [coder encodeObject: self.comments forKey:@"comments"];
    [coder encodeObject: self.attachments forKey:@"attachments"];
    [coder encodeObject: self.remoteUrl forKey:@"remoteUrl"];
    [coder encodeObject: self.uid forKey:@"uid"];
    [coder encodeObject: self.dateModified forKey:@"dateModified"];
    [coder encodeObject: [NSNumber numberWithBool: self.loaded] forKey:@"loaded"];
}
@end
