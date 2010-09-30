// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Signature.m instead.

#import "_Signature.h"

@implementation SignatureID
@end

@implementation _Signature



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

- (SignatureID*)objectID {
	return (SignatureID*)[super objectID];
}






@end
