// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentLink.m instead.

#import "_DocumentLink.h"

@implementation DocumentLinkID
@end

@implementation _DocumentLink



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentLink" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocumentLink";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocumentLink" inManagedObjectContext:moc_];
}

- (DocumentLinkID*)objectID {
	return (DocumentLinkID*)[super objectID];
}




@dynamic index;



- (short)indexValue {
	NSNumber *result = [self index];
	return [result shortValue];
}

- (void)setIndexValue:(short)value_ {
	[self setIndex:[NSNumber numberWithShort:value_]];
}

- (short)primitiveIndexValue {
	NSNumber *result = [self primitiveIndex];
	return [result shortValue];
}

- (void)setPrimitiveIndexValue:(short)value_ {
	[self setPrimitiveIndex:[NSNumber numberWithShort:value_]];
}





@dynamic document;

	



@end
