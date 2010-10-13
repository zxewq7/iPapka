// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommentAudio.h instead.

#import <CoreData/CoreData.h>
#import "FileField.h"

@class Comment;


@interface CommentAudioID : NSManagedObjectID {}
@end

@interface _CommentAudio : FileField {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommentAudioID*)objectID;




@property (nonatomic, retain) Comment* comment;
//- (BOOL)validateComment:(id*)value_ error:(NSError**)error_;



@end

@interface _CommentAudio (CoreDataGeneratedAccessors)

@end

@interface _CommentAudio (CoreDataGeneratedPrimitiveAccessors)



- (Comment*)primitiveComment;
- (void)setPrimitiveComment:(Comment*)value;


@end
