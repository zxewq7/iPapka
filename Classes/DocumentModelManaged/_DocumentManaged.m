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





@dynamic uid;






@dynamic dataSourceId;






@dynamic isArchived;



- (BOOL)isArchivedValue {
	NSNumber *result = [self isArchived];
	return [result boolValue];
}

- (void)setIsArchivedValue:(BOOL)value_ {
	[self setIsArchived:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsArchivedValue {
	NSNumber *result = [self primitiveIsArchived];
	return [result boolValue];
}

- (void)setPrimitiveIsArchivedValue:(BOOL)value_ {
	[self setPrimitiveIsArchived:[NSNumber numberWithBool:value_]];
}





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





@dynamic dateModified;






@dynamic isDeclined;



- (BOOL)isDeclinedValue {
	NSNumber *result = [self isDeclined];
	return [result boolValue];
}

- (void)setIsDeclinedValue:(BOOL)value_ {
	[self setIsDeclined:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsDeclinedValue {
	NSNumber *result = [self primitiveIsDeclined];
	return [result boolValue];
}

- (void)setPrimitiveIsDeclinedValue:(BOOL)value_ {
	[self setPrimitiveIsDeclined:[NSNumber numberWithBool:value_]];
}





@dynamic isAccepted;



- (BOOL)isAcceptedValue {
	NSNumber *result = [self isAccepted];
	return [result boolValue];
}

- (void)setIsAcceptedValue:(BOOL)value_ {
	[self setIsAccepted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsAcceptedValue {
	NSNumber *result = [self primitiveIsAccepted];
	return [result boolValue];
}

- (void)setPrimitiveIsAcceptedValue:(BOOL)value_ {
	[self setPrimitiveIsAccepted:[NSNumber numberWithBool:value_]];
}





@dynamic title;






@dynamic author;

	



@end
