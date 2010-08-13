//
//  Attachment.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Attachment.h"


@implementation Attachment
@synthesize title, remoteUrl;

- (void) dealloc
{
    self.title = nil;
    [_icon release];
    self.remoteUrl = nil;
    [super dealloc];
}
@dynamic icon;
-(UIImage *)icon
{
    if (_icon == nil)
        _icon = [UIImage imageNamed: @"LoadingAttachment.png"];
    return _icon;
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.title = [coder decodeObjectForKey:@"title"];
        self.remoteUrl = [coder decodeObjectForKey:@"remoteUrl"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.title forKey:@"title"];
    [coder encodeObject: self.remoteUrl forKey:@"remoteUrl"];
}
@end
