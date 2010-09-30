// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PageManaged.m instead.

#import "_PageManaged.h"

@implementation PageManagedID
@end

@implementation _PageManaged



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Page";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Page" inManagedObjectContext:moc_];
}

- (PageManagedID*)objectID {
	return (PageManagedID*)[super objectID];
}




@dynamic isFetched;



- (BOOL)isFetchedValue {
	NSNumber *result = [self isFetched];
	return [result boolValue];
}

- (void)setIsFetchedValue:(BOOL)value_ {
	[self setIsFetched:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsFetchedValue {
	NSNumber *result = [self primitiveIsFetched];
	return [result boolValue];
}

- (void)setPrimitiveIsFetchedValue:(BOOL)value_ {
	[self setPrimitiveIsFetched:[NSNumber numberWithBool:value_]];
}





@dynamic number;



- (short)numberValue {
	NSNumber *result = [self number];
	return [result shortValue];
}

- (void)setNumberValue:(short)value_ {
	[self setNumber:[NSNumber numberWithShort:value_]];
}

- (short)primitiveNumberValue {
	NSNumber *result = [self primitiveNumber];
	return [result shortValue];
}

- (void)setPrimitiveNumberValue:(short)value_ {
	[self setPrimitiveNumber:[NSNumber numberWithShort:value_]];
}





@dynamic angle;



- (float)angleValue {
	NSNumber *result = [self angle];
	return [result floatValue];
}

- (void)setAngleValue:(float)value_ {
	[self setAngle:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveAngleValue {
	NSNumber *result = [self primitiveAngle];
	return [result floatValue];
}

- (void)setPrimitiveAngleValue:(float)value_ {
	[self setPrimitiveAngle:[NSNumber numberWithFloat:value_]];
}





@dynamic attachment;

	



@end
