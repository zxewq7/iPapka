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




@dynamic performers;






@dynamic resolution;

	



@end
