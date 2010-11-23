// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RootDocument.m instead.

#import "_RootDocument.h"

@implementation RootDocumentID
@end

@implementation _RootDocument



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RootDocument" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RootDocument";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RootDocument" inManagedObjectContext:moc_];
}

- (RootDocumentID*)objectID {
	return (RootDocumentID*)[super objectID];
}




@dynamic author;






@dynamic createdStripped;






@dynamic created;






@dynamic date;






@dynamic docVersion;






@dynamic modified;






@dynamic text;






@dynamic isRead;



- (BOOL)isReadValue {
	NSNumber *result = [self isRead];
	return [result boolValue];
}

- (void)setIsReadValue:(BOOL)value_ {
	[self setIsRead:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsReadValue {
	NSNumber *result = [self primitiveIsRead];
	return [result boolValue];
}

- (void)setPrimitiveIsReadValue:(BOOL)value_ {
	[self setPrimitiveIsRead:[NSNumber numberWithBool:value_]];
}





@dynamic contentVersion;






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





@dynamic title;






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








@end
