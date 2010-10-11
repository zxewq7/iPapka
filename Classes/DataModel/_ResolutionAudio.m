// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ResolutionAudio.m instead.

#import "_ResolutionAudio.h"

@implementation ResolutionAudioID
@end

@implementation _ResolutionAudio



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ResolutionAudio" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ResolutionAudio";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ResolutionAudio" inManagedObjectContext:moc_];
}

- (ResolutionAudioID*)objectID {
	return (ResolutionAudioID*)[super objectID];
}




@dynamic parent;

	



@end
