// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FileField.m instead.

#import "_FileField.h"

@implementation FileFieldID
@end

@implementation _FileField



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FileField" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FileField";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FileField" inManagedObjectContext:moc_];
}

- (FileFieldID*)objectID {
	return (FileFieldID*)[super objectID];
}




@dynamic name;






@dynamic path;






@dynamic url;






@dynamic syncStatus;



- (short)syncStatusValue {
	NSNumber *result = [self syncStatus];
	return [result shortValue];
}

- (void)setSyncStatusValue:(short)value_ {
	[self setSyncStatus:[NSNumber numberWithShort:value_]];
}

- (short)primitiveSyncStatusValue {
	NSNumber *result = [self primitiveSyncStatus];
	return [result shortValue];
}

- (void)setPrimitiveSyncStatusValue:(short)value_ {
	[self setPrimitiveSyncStatus:[NSNumber numberWithShort:value_]];
}





@dynamic localDateModified;








@end
