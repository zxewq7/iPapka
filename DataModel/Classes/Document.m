//
//  Document.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Document.h"


@implementation Document
@synthesize uid, title, remoteUrl, author, date, comments, attachments, dateModified, loaded;
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
    return [UIImage imageNamed: loaded?@"Signature.png":@"SignatureNotLoaded.png"];
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
