// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.m instead.

#import "_Person.h"

@implementation PersonID
@end

@implementation _Person



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Person";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc_];
}

- (PersonID*)objectID {
	return (PersonID*)[super objectID];
}




@dynamic first;






@dynamic last;






@dynamic lastInitial;






@dynamic uid;






@dynamic middle;






@dynamic resolutions;

	
- (NSMutableSet*)resolutionsSet {
	[self willAccessValueForKey:@"resolutions"];
	NSMutableSet *result = [self mutableSetValueForKey:@"resolutions"];
	[self didAccessValueForKey:@"resolutions"];
	return result;
}
	



@end
