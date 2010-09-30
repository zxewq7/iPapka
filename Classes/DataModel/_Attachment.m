// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Attachment.m instead.

#import "_Attachment.h"

@implementation AttachmentID
@end

@implementation _Attachment

@synthesize pagesOrdered;



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Attachment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Attachment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Attachment" inManagedObjectContext:moc_];
}

- (AttachmentID*)objectID {
	return (AttachmentID*)[super objectID];
}




@dynamic uid;






@dynamic title;






@dynamic document;

	

@dynamic pages;

	
- (NSMutableSet*)pagesSet {
	[self willAccessValueForKey:@"pages"];
	NSMutableSet *result = [self mutableSetValueForKey:@"pages"];
	[self didAccessValueForKey:@"pages"];
	return result;
}
	



@end
