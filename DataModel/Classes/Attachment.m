//
//  Attachment.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Attachment.h"


@implementation Attachment
@synthesize title, pages, isLoaded, hasError, path, uid;

- (void) dealloc
{
    self.title = nil;
    self.pages = nil;
    self.uid = nil;
    self.path = nil;
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

-(UIImage *) pageForIndex:(NSUInteger) anIndex
{
    NSString *imageName = [pages objectAtIndex:anIndex];
    if ([imageName isEqualToString:@"error"]) 
        return [UIImage imageNamed:@"PageError.png"];
    else if ([imageName isEqualToString:@""]) 
        return [UIImage imageNamed:@"PageLoading.png"];

    NSString *imagePath = [path stringByAppendingPathComponent:[pages objectAtIndex:anIndex]];
    return [UIImage imageWithContentsOfFile:imagePath];
}
@end
