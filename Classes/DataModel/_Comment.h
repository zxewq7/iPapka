// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comment.h instead.

#import <CoreData/CoreData.h>


@class Document;
@class CommentAudio;




@interface CommentID : NSManagedObjectID {}
@end

@interface _Comment : NSManagedObject {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommentID*)objectID;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Document* document;
//- (BOOL)validateDocument:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) CommentAudio* audio;
//- (BOOL)validateAudio:(id*)value_ error:(NSError**)error_;



@end

@interface _Comment (CoreDataGeneratedAccessors)

@end

@interface _Comment (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;




- (Document*)primitiveDocument;
- (void)setPrimitiveDocument:(Document*)value;



- (CommentAudio*)primitiveAudio;
- (void)setPrimitiveAudio:(CommentAudio*)value;


@end
