//
//  AttachmentPage.m
//  DataModel
//
//  Created by Vladimir Solomenchuk on 29.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttachmentPage.h"

@implementation AttachmentPage
@synthesize name, drawings, isLoaded, hasError, path;

- (NSString *) drawingsPath
{
    return [[path stringByAppendingPathComponent:self.name] stringByAppendingString:@".drawings.png"];
}

- (UIImage *) drawings
{
    if (!drawings)
    {
        drawings = [UIImage imageWithContentsOfFile: [self drawingsPath]];
        [drawings retain];
    }
    return drawings;
}

- (void) setDrawings:(UIImage *) aDrawings;
{
    if (drawings == aDrawings) 
        return;
    removeDrawings = aDrawings == nil;
    drawings = [aDrawings retain];
}

-(UIImage *) image
{
    if (hasError || !isLoaded) 
        return nil;
    
    NSString *imagePath = [path stringByAppendingPathComponent:name];
    return [UIImage imageWithContentsOfFile:imagePath];
}


- (void) dealloc
{
    [drawings release];
    self.path = nil;
    self.name = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.name = [coder decodeObjectForKey:@"name"];
        self.path = [coder decodeObjectForKey:@"path"];

        self.isLoaded = [[coder decodeObjectForKey:@"isLoaded"] boolValue];
        self.hasError = [[coder decodeObjectForKey:@"hasError"] boolValue];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.name forKey:@"name"];
    [coder encodeObject: self.path forKey:@"path"];

    if (removeDrawings)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self drawingsPath] error:NULL];
        removeDrawings = NO;
    }
    else if (drawings)
    {
        NSData *imageData = UIImagePNGRepresentation(drawings);
        [imageData writeToFile: [self drawingsPath] atomically:YES];
    }

    [coder encodeObject: [NSNumber numberWithBool:self.hasError] forKey:@"hasError"];
    [coder encodeObject: [NSNumber numberWithBool:self.isLoaded] forKey:@"isLoaded"];
}

@end
