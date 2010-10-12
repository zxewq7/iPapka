// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AttachmentPageDrawings.m instead.

#import "_AttachmentPageDrawings.h"

@implementation AttachmentPageDrawingsID
@end

@implementation _AttachmentPageDrawings



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AttachmentPageDrawings" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AttachmentPageDrawings";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AttachmentPageDrawings" inManagedObjectContext:moc_];
}

- (AttachmentPageDrawingsID*)objectID {
	return (AttachmentPageDrawingsID*)[super objectID];
}




@dynamic parent;

	



@end
