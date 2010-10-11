// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SignatureAudio.m instead.

#import "_SignatureAudio.h"

@implementation SignatureAudioID
@end

@implementation _SignatureAudio



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SignatureAudio" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SignatureAudio";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SignatureAudio" inManagedObjectContext:moc_];
}

- (SignatureAudioID*)objectID {
	return (SignatureAudioID*)[super objectID];
}




@dynamic parent;

	



@end
