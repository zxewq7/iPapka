//
//  Folder.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 19.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"
#import "DocumentResolution.h"
#import "DocumentSignature.h"
#import "DataSource.h"

@implementation Folder
@synthesize name, predicateString, entityName, icon, iconName, filters, sortDescriptors;

+(id)folderWithName:(NSString *) aName 
    predicateString:(NSString *) aPredicateString 
    sortDescriprors:(NSArray *)sortDescriptors 
         entityName:(NSString *) anEntityName 
           iconName:(NSString *) anIconName
{
    Folder *folder = [[Folder alloc] init];
    folder.name = aName;
    folder.predicateString = aPredicateString;
    folder.entityName = anEntityName;
    folder.iconName = anIconName;
    folder.sortDescriptors = sortDescriptors;
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
    
    self.sortDescriptors = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if ((self = [super init]))
    {
        self.name = [coder decodeObjectForKey:@"name"];
        self.predicateString = [coder decodeObjectForKey:@"predicateString"];
        self.entityName = [coder decodeObjectForKey:@"entityName"];
        self.iconName = [coder decodeObjectForKey:@"iconName"];
        self.filters = [coder decodeObjectForKey:@"filters"];
        self.sortDescriptors = [coder decodeObjectForKey:@"sortDescriptors"];
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
    [coder encodeObject: self.sortDescriptors forKey:@"sortDescriptors"];
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
        if ([entityName isEqualToString:@"DocumentResolution"])
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
    NSFetchedResultsController *documents = [[DataSource sharedDataSource] documentsForFolder:self];
    return documents;
}

- (DocumentRoot*) firstDocument
{
    NSFetchedResultsController *documents = self.documents;

    NSError *error = nil;
    if (![documents performFetch:&error])
        NSAssert1(NO, @"Unhandled error executing count unread document: %@", [error localizedDescription]);

    NSArray *objects = [documents fetchedObjects];
    if ([objects count])
        return [objects objectAtIndex:0];
    
    return nil;
}
@end
