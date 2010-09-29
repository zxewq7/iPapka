// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ResolutionManaged.m instead.

#import "_ResolutionManaged.h"

@implementation ResolutionManagedID
@end

@implementation _ResolutionManaged

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Resolution" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Resolution";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Resolution" inManagedObjectContext:moc_];
}

- (ResolutionManagedID*)objectID {
	return (ResolutionManagedID*)[super objectID];
}




@dynamic isManaged;



- (BOOL)isManagedValue {
	NSNumber *result = [self isManaged];
	return [result boolValue];
}

- (void)setIsManagedValue:(BOOL)value_ {
	[self setIsManaged:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsManagedValue {
	NSNumber *result = [self primitiveIsManaged];
	return [result boolValue];
}

- (void)setPrimitiveIsManagedValue:(BOOL)value_ {
	[self setPrimitiveIsManaged:[NSNumber numberWithBool:value_]];
}





@dynamic deadline;






@dynamic text;






@dynamic performers;

	
- (NSMutableSet*)performersSet {
	[self willAccessValueForKey:@"performers"];
	NSMutableSet *result = [self mutableSetValueForKey:@"performers"];
	[self didAccessValueForKey:@"performers"];
	return result;
}
	

@dynamic parentResolution;

	



@end
