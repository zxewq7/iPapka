// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AttachmentPage.m instead.

#import "_AttachmentPage.h"

@implementation AttachmentPageID
@end

@implementation _AttachmentPage



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AttachmentPage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AttachmentPage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AttachmentPage" inManagedObjectContext:moc_];
}

- (AttachmentPageID*)objectID {
	return (AttachmentPageID*)[super objectID];
}




@dynamic syncStatus;



- (short)syncStatusValue {
	NSNumber *result = [self syncStatus];
	return [result shortValue];
}

- (void)setSyncStatusValue:(short)value_ {
	[self setSyncStatus:[NSNumber numberWithShort:value_]];
}

- (short)primitiveSyncStatusValue {
	NSNumber *result = [self primitiveSyncStatus];
	return [result shortValue];
}

- (void)setPrimitiveSyncStatusValue:(short)value_ {
	[self setPrimitiveSyncStatus:[NSNumber numberWithShort:value_]];
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

	

@dynamic painting;

	



@end
