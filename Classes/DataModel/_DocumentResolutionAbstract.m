// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolutionAbstract.m instead.

#import "_DocumentResolutionAbstract.h"

@implementation DocumentResolutionAbstractID
@end

@implementation _DocumentResolutionAbstract



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentResolutionAbstract" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocumentResolutionAbstract";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocumentResolutionAbstract" inManagedObjectContext:moc_];
}

- (DocumentResolutionAbstractID*)objectID {
	return (DocumentResolutionAbstractID*)[super objectID];
}




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








@end
