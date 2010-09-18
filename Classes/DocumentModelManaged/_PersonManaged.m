// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PersonManaged.m instead.

#import "_PersonManaged.h"

@implementation PersonManagedID
@end

@implementation _PersonManaged

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

- (PersonManagedID*)objectID {
	return (PersonManagedID*)[super objectID];
}




@dynamic first;






@dynamic last;






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
