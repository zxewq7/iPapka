// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolution.m instead.

#import "_DocumentResolution.h"

@implementation DocumentResolutionID
@end

@implementation _DocumentResolution



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentResolution" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocumentResolution";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocumentResolution" inManagedObjectContext:moc_];
}

- (DocumentResolutionID*)objectID {
	return (DocumentResolutionID*)[super objectID];
}




@dynamic text;






@dynamic deadline;






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





@dynamic parentResolution;

	

@dynamic performers;

	
- (NSMutableSet*)performersSet {
	[self willAccessValueForKey:@"performers"];
	NSMutableSet *result = [self mutableSetValueForKey:@"performers"];
	[self didAccessValueForKey:@"performers"];
	return result;
}
	



@end
