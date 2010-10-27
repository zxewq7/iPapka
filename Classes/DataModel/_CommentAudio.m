// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommentAudio.m instead.

#import "_CommentAudio.h"

@implementation CommentAudioID
@end

@implementation _CommentAudio



+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CommentAudio" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CommentAudio";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CommentAudio" inManagedObjectContext:moc_];
}

- (CommentAudioID*)objectID {
	return (CommentAudioID*)[super objectID];
}




@dynamic document;

	



@end
