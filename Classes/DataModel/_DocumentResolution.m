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




@dynamic registrationNumber;






@dynamic performers;

	
- (NSMutableSet*)performersSet {
	[self willAccessValueForKey:@"performers"];
	NSMutableSet *result = [self mutableSetValueForKey:@"performers"];
	[self didAccessValueForKey:@"performers"];
	return result;
}
	

@dynamic parentResolution;

	



@end
