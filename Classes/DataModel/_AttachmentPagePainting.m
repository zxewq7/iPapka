// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AttachmentPagePainting.m instead.

#import "_AttachmentPagePainting.h"

@implementation AttachmentPagePaintingID
@end

@implementation _AttachmentPagePainting



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AttachmentPagePainting" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AttachmentPagePainting";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AttachmentPagePainting" inManagedObjectContext:moc_];
}

- (AttachmentPagePaintingID*)objectID {
	return (AttachmentPagePaintingID*)[super objectID];
}




@dynamic page;

	



@end
