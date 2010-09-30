// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SignatureManaged.m instead.

#import "_SignatureManaged.h"

@implementation SignatureManagedID
@end

@implementation _SignatureManaged



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Signature" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Signature";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Signature" inManagedObjectContext:moc_];
}

- (SignatureManagedID*)objectID {
	return (SignatureManagedID*)[super objectID];
}






@end
