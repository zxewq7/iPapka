// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommentAudio.h instead.

#import <CoreData/CoreData.h>
#import "FileField.h"

@class Document;


@interface CommentAudioID : NSManagedObjectID {}
@end

@interface _CommentAudio : FileField {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommentAudioID*)objectID;




@property (nonatomic, retain) Document* document;
//- (BOOL)validateDocument:(id*)value_ error:(NSError**)error_;



@end

@interface _CommentAudio (CoreDataGeneratedAccessors)

@end

@interface _CommentAudio (CoreDataGeneratedPrimitiveAccessors)



- (Document*)primitiveDocument;
- (void)setPrimitiveDocument:(Document*)value;


@end
