//
//  Folder.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 19.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"
#import "DocumentManaged.h"
#import "ResolutionManaged.h"
#import "SignatureManaged.h"

@implementation Folder
@synthesize name, predicateString, entityName, icon, iconName;

+(id)folderWithName:(NSString *) aName predicateString:(NSString *) aPredicateString entityName:(NSString *) anEntityName iconName:(NSString *) anIconName
{
    Folder *folder = [[Folder alloc] init];
    folder.name = aName;
    folder.predicateString = aPredicateString;
    folder.entityName = anEntityName;
    folder.iconName = anIconName;
    return [folder autorelease];
}

- (void) dealloc
{
    self.name = nil;
    self.predicateString = nil;
    self.entityName = nil;
    [predicate release];
    [localizedName release];
    self.iconName = nil;
    [icon release];
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
        self.entityName = [coder decodeObjectForKey:@"entityName"];
        self.iconName = [coder decodeObjectForKey:@"iconName"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.name forKey:@"name"];
    [coder encodeObject: self.predicateString forKey:@"predicateString"];
    [coder encodeObject: self.entityName forKey:@"entityName"];
    [coder encodeObject: self.iconName forKey:@"iconName"];
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

-(void)setIconName:(NSString *)anIconName
{
    if (iconName == anIconName)
        return;
    [iconName release];
    iconName = [anIconName retain];
    [icon release];
    icon = nil;
}

-(UIImage *) icon
{
    if (icon == nil && iconName != nil)
        icon = [[UIImage imageNamed: iconName] retain];
    return icon;
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
    if (predicateString != nil && predicate == nil)
    {
        predicate = [NSPredicate predicateWithFormat:predicateString];
        [predicate retain];
    }
    return predicate;
}

-(void)setEntityName:(NSString *)anEntityName
{
    if (entityName == anEntityName)
        return;
    [entityName release];
    entityName = [anEntityName retain];
    entityClass = nil;
}


-(Class) entityClass
{
    if (entityClass == nil) 
    {
        if ([entityName isEqualToString:@"Document"])
            entityClass = [DocumentManaged class];
        else if ([entityName isEqualToString:@"Resolution"])
            entityClass = [ResolutionManaged class];
        else if ([entityName isEqualToString:@"Signature"])
            entityClass = [SignatureManaged class];
        else
            NSAssert1(NO, @"Unknown entity name: %@", entityName);
    }
   return entityClass;
}
@end
