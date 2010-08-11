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
@end
