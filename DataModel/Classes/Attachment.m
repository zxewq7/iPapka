//
//  Attachment.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Attachment.h"
#import "AttachmentPage.h"

@implementation Attachment
@synthesize title, pages, isLoaded, hasError, path, uid;

- (void) dealloc
{
    self.title = nil;
    self.pages = nil;
    self.uid = nil;
    [path release];
    path = nil;
    [super dealloc];
}

-(void) setPath: (NSString *) aPath
{
    if (path == aPath || [path isEqualToString: aPath])
        return;
    [path release];
    path = [aPath retain];
    
    [pages makeObjectsPerformSelector:@selector(setPath:) withObject: path];
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.title = [coder decodeObjectForKey:@"title"];
        self.pages = [coder decodeObjectForKey:@"pages"];
        path = [[coder decodeObjectForKey:@"path"] retain];
        self.uid = [coder decodeObjectForKey:@"uid"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.title forKey:@"title"];
    [coder encodeObject: self.pages forKey:@"pages"];
    [coder encodeObject: self.path forKey:@"path"];
    [coder encodeObject: self.uid forKey:@"uid"];
}
@end
