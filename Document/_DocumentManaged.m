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




@dynamic author;






@dynamic title;






@dynamic dateModified;






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





@dynamic date;








@end