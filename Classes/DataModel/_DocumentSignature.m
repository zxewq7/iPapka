// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentSignature.m instead.

#import "_DocumentSignature.h"

@implementation DocumentSignatureID
@end

@implementation _DocumentSignature



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocumentSignature" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocumentSignature";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocumentSignature" inManagedObjectContext:moc_];
}

- (DocumentSignatureID*)objectID {
	return (DocumentSignatureID*)[super objectID];
}






@end
