//
//  Folder.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 19.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"


@implementation Folder
@synthesize name, predicateString;

+(id)folderWith:(NSString *) aName andPredicateString:(NSString *) aPredicateString
{
    Folder *folder = [[Folder alloc] init];
    folder.name = aName;
    folder.predicateString = aPredicateString;
    return [folder autorelease];
}

- (void) dealloc
{
    self.name = nil;
    self.predicateString = nil;
    [predicate release];
    [localizedName release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.name = [coder decodeObjectForKey:@"name"];
        self.predicateString = [coder decodeObjectForKey:@"predicateString"];
        
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.name forKey:@"name"];
    [coder encodeObject: self.predicateString forKey:@"predicateString"];
}

-(void)setName:(NSString *)aName
{
    if (name == aName)
        return;
    [name release];
    name = [aName retain];
    [localizedName release];
    localizedName = nil;
}

-(void)setPredicateString:(NSString *)aPredicateString
{
    if (predicateString == aPredicateString)
        return;
    [predicateString release];
    predicateString = [aPredicateString retain];
    [predicate release];
    predicate = nil;
}


- (NSString *) localizedName
{
    if (localizedName == nil)
    {
        localizedName = NSLocalizedString(name, "Folder name");
        [localizedName retain];
    }
    return localizedName;
}
- (NSPredicate *) predicate
{
    if (predicate == nil)
    {
        predicate = [NSPredicate predicateWithFormat:predicateString];
        [predicate retain];
    }
    return predicate;
}
@end
