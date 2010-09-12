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





@dynamic author;






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






@dynamic title;








@end
