//
//  Document.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Document.h"


@implementation Document
@synthesize uid, title, remoteUrl, icon, author, date, text, performers, managed, comments, attachments;
- (void) dealloc
{
    self.title = nil;
    self.icon = nil;
    self.author = nil;
    self.date = nil;
    self.text = nil;
    self.performers = nil;
    self.comments = nil;
    self.attachments = nil;
    self.remoteUrl = nil;
    self.uid = nil;
    [super dealloc];
}
@end
