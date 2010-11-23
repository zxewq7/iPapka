// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentWithResources.m instead.

#import "_DocumentWithResources.h"

@implementation DocumentWithResourcesID
@end

@implementation _DocumentWithResources



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentWithResources" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocumentWithResources";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocumentWithResources" inManagedObjectContext:moc_];
}

- (DocumentWithResourcesID*)objectID {
	return (DocumentWithResourcesID*)[super objectID];
}




@dynamic linksOrdering;






@dynamic attachmentsOrdering;






@dynamic uid;






@dynamic path;






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





@dynamic attachments;

	
- (NSMutableSet*)attachmentsSet {
	[self willAccessValueForKey:@"attachments"];
	NSMutableSet *result = [self mutableSetValueForKey:@"attachments"];
	[self didAccessValueForKey:@"attachments"];
	return result;
}
	

@dynamic audio;

	

@dynamic links;

	
- (NSMutableSet*)linksSet {
	[self willAccessValueForKey:@"links"];
	NSMutableSet *result = [self mutableSetValueForKey:@"links"];
	[self didAccessValueForKey:@"links"];
	return result;
}
	



@end
