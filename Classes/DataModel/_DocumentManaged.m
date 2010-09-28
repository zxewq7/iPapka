// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentManaged.m instead.

#import "_DocumentManaged.h"

@implementation DocumentManagedID
@end

@implementation _DocumentManaged

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Document" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Document";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Document" inManagedObjectContext:moc_];
}

- (DocumentManagedID*)objectID {
	return (DocumentManagedID*)[super objectID];
}




@dynamic isModified;



- (BOOL)isModifiedValue {
	NSNumber *result = [self isModified];
	return [result boolValue];
}

- (void)setIsModifiedValue:(BOOL)value_ {
	[self setIsModified:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsModifiedValue {
	NSNumber *result = [self primitiveIsModified];
	return [result boolValue];
}

- (void)setPrimitiveIsModifiedValue:(BOOL)value_ {
	[self setPrimitiveIsModified:[NSNumber numberWithBool:value_]];
}





@dynamic uid;






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





@dynamic isEditable;



- (BOOL)isEditableValue {
	NSNumber *result = [self isEditable];
	return [result boolValue];
}

- (void)setIsEditableValue:(BOOL)value_ {
	[self setIsEditable:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsEditableValue {
	NSNumber *result = [self primitiveIsEditable];
	return [result boolValue];
}

- (void)setPrimitiveIsEditableValue:(BOOL)value_ {
	[self setPrimitiveIsEditable:[NSNumber numberWithBool:value_]];
}





@dynamic dateModified;






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





@dynamic isSynced;



- (BOOL)isSyncedValue {
	NSNumber *result = [self isSynced];
	return [result boolValue];
}

- (void)setIsSyncedValue:(BOOL)value_ {
	[self setIsSynced:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsSyncedValue {
	NSNumber *result = [self primitiveIsSynced];
	return [result boolValue];
}

- (void)setPrimitiveIsSyncedValue:(BOOL)value_ {
	[self setPrimitiveIsSynced:[NSNumber numberWithBool:value_]];
}





@dynamic title;






@dynamic links;

	
- (NSMutableSet*)linksSet {
	[self willAccessValueForKey:@"links"];
	NSMutableSet *result = [self mutableSetValueForKey:@"links"];
	[self didAccessValueForKey:@"links"];
	return result;
}
	

@dynamic author;

	

@dynamic parent;

	

@dynamic attachments;

	
- (NSMutableSet*)attachmentsSet {
	[self willAccessValueForKey:@"attachments"];
	NSMutableSet *result = [self mutableSetValueForKey:@"attachments"];
	[self didAccessValueForKey:@"attachments"];
	return result;
}
	



@end
