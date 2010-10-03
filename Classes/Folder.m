//
//  Folder.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 19.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"
#import "Document.h"
#import "DocumentResolution.h"
#import "DocumentSignature.h"
#import "DataSource.h"

@implementation Folder
@synthesize name, predicateString, entityName, icon, iconName, filters;

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
    [predicate release]; predicate = nil;
    [localizedName release]; self.iconName = nil;
    [icon release]; icon = nil;
    self.filters = nil;
    [documents release]; documents = nil;
    
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
        self.filters = [coder decodeObjectForKey:@"filters"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.name forKey:@"name"];
    [coder encodeObject: self.predicateString forKey:@"predicateString"];
    [coder encodeObject: self.entityName forKey:@"entityName"];
    [coder encodeObject: self.iconName forKey:@"iconName"];
    [coder encodeObject: self.filters forKey:@"filters"];
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
            entityClass = [Document class];
        else if ([entityName isEqualToString:@"DocumentResolution"])
            entityClass = [DocumentResolution class];
        else if ([entityName isEqualToString:@"DocumentSignature"])
            entityClass = [DocumentSignature class];
        else
            NSAssert1(NO, @"Unknown entity name: %@", entityName);
    }
   return entityClass;
}

- (NSUInteger) countUnread
{
    return [[DataSource sharedDataSource] countUnreadDocumentsForFolder:self];
}
- (NSFetchedResultsController*) documents
{
    if (!documents)
    {
        documents = [[DataSource sharedDataSource] documentsForFolder:self];
        [documents retain];
        NSError *error = nil;
        if (![documents performFetch:&error])
            NSAssert1(NO, @"Unhandled error executing count unread document: %@", [error localizedDescription]);
        
    }
    
    return documents;
}
- (Document*) firstDocument
{
    NSUInteger sectionsCount = [[self.documents sections] count];
    
    for (NSUInteger sectionIndex = 0; sectionIndex < sectionsCount; sectionIndex++)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.documents sections] objectAtIndex:sectionIndex];
        if ([sectionInfo numberOfObjects])
            return [self.documents objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
    }
    
    return nil;
}
@end
