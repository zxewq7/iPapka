//
//  BWOrderedManagedObject.m
//  OrderedCoreDataDemo
//
//  Created by Brian Webster on 8/5/08.
//  Copyright 2008 Fat Cat Software. Some rights reserved <http://opensource.org/licenses/mit-license.php>
//

#import "BWOrderedManagedObject.h"

@interface BWOrderedValueProxy : NSMutableArray
{
	BWOrderedManagedObject*		container;
	NSString*					key;
}

- (id)initWithContainer:(BWOrderedManagedObject*)inContainer key:(NSString*)inKey;

@end

@implementation BWOrderedValueProxy

+ (BWOrderedValueProxy*)orderedValueProxyWithContainer:(BWOrderedManagedObject*)inContainer key:(NSString*)inKey;
{
	return [[[BWOrderedValueProxy alloc] initWithContainer:inContainer key:inKey] autorelease];
}

- (id)initWithContainer:(BWOrderedManagedObject*)inContainer key:(NSString*)inKey
{
	if ((self = [super init]))
	{
		container = [inContainer retain];
		key = [inKey copy];
	}
	return self;
}

- (void)dealloc
{
	[container release];
	[key release];
	[super dealloc];
}

- (unsigned)count
{
	return [container countOfOrderedValueForKey:key];
}

- (id)objectAtIndex:(NSUInteger)index
{
	return [container objectInOrderedValueForKey:key atIndex:index];
}

- (void)addObject:(id)anObject
{
	[self insertObject:anObject atIndex:[self count]];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
	[container insertObject:object inOrderedValueForKey:key atIndex:index];
}

- (void)removeLastObject
{
	[self removeObjectAtIndex:[self count] - 1];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
	[container removeObjectFromOrderedValueForKey:key atIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	[container replaceObjectInOrderedValueForKey:key atIndex:index withObject:anObject];
}

- (NSUInteger)indexOfObject:(id)anObject
{
    NSUInteger count = [container countOfOrderedValueForKey:key];

    for (NSUInteger i = 0; i < count; i++)
    {
        id object = [container objectInOrderedValueForKey:key atIndex:i];
        if ([object isEqual:anObject])
            return i;
    }
    return NSNotFound;
}
@end

NSString* BWOrderedChangeContext = @"BWOrderedChangeContext";

@implementation BWOrderedManagedObject

//We need to observe the underlying relationship via KVO so that we can catch object insertions
//and deletions that come directly to the relationship, rather than through the ordered
//relationship methods.
- (void)observeOrderedRelationships
{
	NSEnumerator*		enumerator;
	NSString*			relationshipKey;

	enumerator = [[self orderedKeys] objectEnumerator];
	while ((relationshipKey = [enumerator nextObject])) 
	{
		[self addObserver:self forKeyPath:relationshipKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:BWOrderedChangeContext];
	}
}

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[self observeOrderedRelationships];
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	[self observeOrderedRelationships];
}

//Newly inserted objects in the managed object context are first assigned a temporary ID, and
//then given a different, permanent ID upon being commited to a persistent store.  We want our
//stored URIs to be the permanent IDs, not the temporary ones, so when we're about to be saved,
//we force the child objects to be assigned permanent IDs so that we can store those and not
//the temporary ones.
- (void)willSave
{
	NSEnumerator*	enumerator;
	NSString*		key;
	NSError*		error = nil;

	enumerator = [[self orderedKeys] objectEnumerator];
	while ((key = [enumerator nextObject])) 
	{
		NSArray*	orderedObjects = [self orderedValueForKey:key];
		
		if ([[self managedObjectContext] obtainPermanentIDsForObjects:[self orderedValueForKey:key] error:&error])
		{
			[self setPrimitiveValue:[orderedObjects valueForKeyPath:@"objectID.URIRepresentation"] forKey:[self orderingKeyForRelationshipKey:key]];
		}
		else
		{
			NSLog(@"error obtaining permanent ID for %@: %@", [self orderedValueForKey:key], error);
		}
	}
}

- (NSString*)orderingKeyForRelationshipKey:(NSString*)key
{
	return [key stringByAppendingString:@"Ordering"];
}

- (NSArray*)orderedKeys
{
	NSMutableArray*		orderedKeys = [[NSMutableArray alloc] init];
	NSEnumerator*		enumerator;
	NSString*			key;

	enumerator = [[[self entity] relationshipsByName] keyEnumerator];
	while ((key = [enumerator nextObject])) 
	{
		NSString* orderingKey = [self orderingKeyForRelationshipKey:key];
		
		if ([[[self entity] propertiesByName] objectForKey:orderingKey] != nil)
			[orderedKeys addObject:key];
	}
	return [orderedKeys autorelease];
}

- (NSArray*)orderingForKey:(NSString*)key
{
	NSArray*	ordering = nil;
	NSString*	orderingKey = [self orderingKeyForRelationshipKey:key];
	
	if ([[[self entity] propertiesByName] objectForKey:orderingKey] != nil)
	{
		ordering =  [self valueForKey:orderingKey];
		if (ordering == nil)
			ordering = [NSArray array];
	}
	return ordering;
}

- (void)setOrdering:(NSArray*)newOrdering forKey:(NSString*)key
{
	NSString*	orderingKey = [self orderingKeyForRelationshipKey:key];
	
	NSAssert2([[[self entity] propertiesByName] objectForKey:orderingKey] != nil, @"No ordering available for key \"%@\". You must declare the key \"%@\" in your object model", key, orderingKey);
	//NSLog(@"newOrdering = %@", newOrdering);
	[self setValue:newOrdering forKey:orderingKey];
}

- (NSArray*)orderedValueForKey:(NSString*)key
{
	return [[[BWOrderedValueProxy orderedValueProxyWithContainer:self key:key] copy] autorelease];
}

- (NSMutableArray*)mutableOrderedValueForKey:(NSString*)key
{
	return [BWOrderedValueProxy orderedValueProxyWithContainer:self key:key];
}

- (unsigned)countOfOrderedValueForKey:(NSString*)key
{
	return [[self primitiveValueForKey:key] count];
}

- (NSManagedObject*)objectInOrderedValueForKey:(NSString*)key atIndex:(NSUInteger)index
{
	NSArray*			ordering = [self orderingForKey:key];
	NSURL*				objectURI = [ordering objectAtIndex:index];
	NSManagedObjectID*	objectID = [[[self managedObjectContext] persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
	NSManagedObject*	object = [[self managedObjectContext] objectWithID:objectID];
	
	return object;    
}

- (void)insertObject:(NSManagedObject*)object inOrderedValueForKey:(NSString*)key atIndex:(NSUInteger)index
{
	NSMutableArray*		newOrdering = [[self orderingForKey:key] mutableCopy];
	
	//NSLog(@"inserting %@ at %d", object, index);
	[newOrdering insertObject:[[object objectID] URIRepresentation] atIndex:index];
	[self setOrdering:newOrdering forKey:key];
	[[self mutableSetValueForKey:key] addObject:object];
	[newOrdering release];
}

- (void)removeObjectFromOrderedValueForKey:(NSString*)key atIndex:(NSUInteger)index
{
	NSMutableArray* newOrdering = [[self orderingForKey:key] mutableCopy];
	NSManagedObjectID* objectID = [[[self managedObjectContext] persistentStoreCoordinator] managedObjectIDForURIRepresentation:[newOrdering objectAtIndex:index]];
	NSManagedObject* object = [[self managedObjectContext] objectRegisteredForID:objectID];
	
	[newOrdering removeObjectAtIndex:index];
	[self setOrdering:newOrdering forKey:key];
	[[self mutableSetValueForKey:key] removeObject:object];
	[newOrdering release];
}

- (void)replaceObjectInOrderedValueForKey:(NSString*)key atIndex:(NSUInteger)index withObject:(NSManagedObject*)newObject
{
	NSMutableArray* newOrdering = [[self orderingForKey:key] mutableCopy];
	NSManagedObjectID* objectID = [[[self managedObjectContext] persistentStoreCoordinator] managedObjectIDForURIRepresentation:[newOrdering objectAtIndex:index]];
	NSManagedObject* oldObject = [[self managedObjectContext] objectRegisteredForID:objectID];
	
	[newOrdering replaceObjectAtIndex:index withObject:newObject];
	[self setOrdering:newOrdering forKey:key];
	[[self mutableSetValueForKey:key] removeObject:oldObject];
	[[self mutableSetValueForKey:key] addObject:newObject];
	[newOrdering release];
}

- (void)moveObjectsInOrderedValueForKey:(NSString*)key fromIndexes:(NSIndexSet*)indexes toIndex:(unsigned)newIndex
{
	NSArray*			oldOrdering = [self orderingForKey:key];
	NSMutableArray*		newOrdering = [[NSMutableArray alloc] init];
	unsigned			i;
	
	//Iterate through the array in its previous order.  Any objects that aren't being moved
	//get inserted in the new array in the same order they were before.  When we hit the index
	//where the objects are being moved to, we insert all the objects being moved at once.
	//We iterate to one above the count for the case where items are dragged to the very end
	//of the list.
	for (i = 0; i <= [oldOrdering count]; i++)
	{
		if (i == newIndex)
		{
			int			index;
			
			for (index = [indexes firstIndex]; index != NSNotFound; index = [indexes indexGreaterThanIndex:index])
			{
				[newOrdering addObject:[oldOrdering objectAtIndex:index]];
			}
		}
		if (![indexes containsIndex:i] && i < [oldOrdering count])
			[newOrdering addObject:[oldOrdering objectAtIndex:i]];
	}
	[self setOrdering:newOrdering forKey:key];
	[newOrdering release];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
	if (context == BWOrderedChangeContext)
	{
		//We listen for changes to the underlying relationship so we can update our ordering
		//even for changes made through normal Core Data methods and not our ordered ones.
		//Deleted objects are removed from the ordering, and newly added objects are simply
		//added to the end of the ordering.
		NSMutableArray*		newOrdering = [[self orderingForKey:keyPath] mutableCopy];
		NSSet*				removedObjects = [change objectForKey:NSKeyValueChangeOldKey];
		NSSet*				addedObjects = [change objectForKey:NSKeyValueChangeNewKey];
		NSEnumerator*		enumerator;
		NSManagedObject*	managedObject;
		BOOL				changedOrdering = NO;

		//NSLog(@"%@ changed: removedObjects = %@, addedObjects = %@", object, removedObjects, addedObjects);
		if ([removedObjects isEqual:[NSNull null]] || ([removedObjects respondsToSelector:@selector(isFault)] && [removedObjects performSelector:@selector(isFault)]))
			removedObjects = nil;
		if ([addedObjects isEqual:[NSNull null]]  || ([addedObjects respondsToSelector:@selector(isFault)] && [addedObjects performSelector:@selector(isFault)]))
			addedObjects = nil;
		enumerator = [removedObjects objectEnumerator];
		while ((managedObject = [enumerator nextObject])) 
		{
			//If a set<Key>: method was called, it's possible for an object to be both in the
			//addedObjects and removedObjects sets, in which case we just ignore it.
			if (![addedObjects containsObject:managedObject])
			{
				[newOrdering removeObject:[[managedObject objectID] URIRepresentation]];
				changedOrdering = YES;
			}
		}
		enumerator = [addedObjects objectEnumerator];
		while ((managedObject = [enumerator nextObject]))
		{
			//If a set<Key>: method was called, it's possible for an object to be both in the
			//addedObjects and removedObjects sets, in which case we just ignore it.
			//Also, we make sure not to add new objects a second time.
			if (![removedObjects containsObject:managedObject] &&
				![newOrdering containsObject:[[managedObject objectID] URIRepresentation]])
			{
				[newOrdering addObject:[[managedObject objectID] URIRepresentation]];
				changedOrdering = YES;
			}
		}
		//A small optimization to prevent unnecessary updates if nothing actually changed
		if (changedOrdering)
			[self setOrdering:newOrdering forKey:keyPath];
		[newOrdering release];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
