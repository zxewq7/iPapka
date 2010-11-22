// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentWithResources.m instead.

#import "_DocumentWithResources.h"

@implementation DocumentWithResourcesID
@end

@implementation _DocumentWithResources



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentWithResources" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocumentWithResources";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocumentWithResources" inManagedObjectContext:moc_];
}

- (DocumentWithResourcesID*)objectID {
	return (DocumentWithResourcesID*)[super objectID];
}




@dynamic author;






@dynamic createdStripped;






@dynamic created;






@dynamic date;






@dynamic modified;






@dynamic text;






@dynamic priority;



- (short)priorityValue {
	NSNumber *result = [self priority];
	return [result shortValue];
}

- (void)setPriorityValue:(short)value_ {
	[self setPriority:[NSNumber numberWithShort:value_]];
}

- (short)primitivePriorityValue {
	NSNumber *result = [self primitivePriority];
	return [result shortValue];
}

- (void)setPrimitivePriorityValue:(short)value_ {
	[self setPrimitivePriority:[NSNumber numberWithShort:value_]];
}





@dynamic linksOrdering;






@dynamic status;



- (short)statusValue {
	NSNumber *result = [self status];
	return [result shortValue];
}

- (void)setStatusValue:(short)value_ {
	[self setStatus:[NSNumber numberWithShort:value_]];
}

- (short)primitiveStatusValue {
	NSNumber *result = [self primitiveStatus];
	return [result shortValue];
}

- (void)setPrimitiveStatusValue:(short)value_ {
	[self setPrimitiveStatus:[NSNumber numberWithShort:value_]];
}





@dynamic dateStripped;






@dynamic correspondents;






@dynamic audio;

	

@dynamic links;

	
- (NSMutableSet*)linksSet {
	[self willAccessValueForKey:@"links"];
	NSMutableSet *result = [self mutableSetValueForKey:@"links"];
	[self didAccessValueForKey:@"links"];
	return result;
}
	



@end
