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




@dynamic title;






@dynamic document;

	



@end
