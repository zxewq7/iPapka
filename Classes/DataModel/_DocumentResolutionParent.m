// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolutionParent.m instead.

#import "_DocumentResolutionParent.h"

@implementation DocumentResolutionParentID
@end

@implementation _DocumentResolutionParent



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentResolutionParent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocumentResolutionParent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocumentResolutionParent" inManagedObjectContext:moc_];
}

- (DocumentResolutionParentID*)objectID {
	return (DocumentResolutionParentID*)[super objectID];
}




@dynamic author;






@dynamic performers;






@dynamic text;






@dynamic isManaged;



- (BOOL)isManagedValue {
	NSNumber *result = [self isManaged];
	return [result boolValue];
}

- (void)setIsManagedValue:(BOOL)value_ {
	[self setIsManaged:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsManagedValue {
	NSNumber *result = [self primitiveIsManaged];
	return [result boolValue];
}

- (void)setPrimitiveIsManagedValue:(BOOL)value_ {
	[self setPrimitiveIsManaged:[NSNumber numberWithBool:value_]];
}





@dynamic deadline;






@dynamic date;






@dynamic resolution;

	



@end
