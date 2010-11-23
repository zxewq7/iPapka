// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentWithResources.h instead.

#import <CoreData/CoreData.h>
#import "BWOrderedManagedObject.h"

@class Attachment;
@class CommentAudio;
@class DocumentLink;

@class NSObject;
@class NSObject;




@interface DocumentWithResourcesID : NSManagedObjectID {}
@end

@interface _DocumentWithResources : BWOrderedManagedObject {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentWithResourcesID*)objectID;



@property (nonatomic, retain) NSObject *linksOrdering;

//- (BOOL)validateLinksOrdering:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *attachmentsOrdering;

//- (BOOL)validateAttachmentsOrdering:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isEditable;

@property BOOL isEditableValue;
- (BOOL)isEditableValue;
- (void)setIsEditableValue:(BOOL)value_;

//- (BOOL)validateIsEditable:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* attachments;
- (NSMutableSet*)attachmentsSet;



@property (nonatomic, retain) CommentAudio* audio;
//- (BOOL)validateAudio:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* links;
- (NSMutableSet*)linksSet;



@end

@interface _DocumentWithResources (CoreDataGeneratedAccessors)

- (void)addAttachments:(NSSet*)value_;
- (void)removeAttachments:(NSSet*)value_;
- (void)addAttachmentsObject:(Attachment*)value_;
- (void)removeAttachmentsObject:(Attachment*)value_;

- (void)addLinks:(NSSet*)value_;
- (void)removeLinks:(NSSet*)value_;
- (void)addLinksObject:(DocumentLink*)value_;
- (void)removeLinksObject:(DocumentLink*)value_;

@end

@interface _DocumentWithResources (CoreDataGeneratedPrimitiveAccessors)

- (NSObject*)primitiveLinksOrdering;
- (void)setPrimitiveLinksOrdering:(NSObject*)value;


- (NSObject*)primitiveAttachmentsOrdering;
- (void)setPrimitiveAttachmentsOrdering:(NSObject*)value;


- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;


- (NSNumber*)primitiveIsEditable;
- (void)setPrimitiveIsEditable:(NSNumber*)value;

- (BOOL)primitiveIsEditableValue;
- (void)setPrimitiveIsEditableValue:(BOOL)value_;




- (NSMutableSet*)primitiveAttachments;
- (void)setPrimitiveAttachments:(NSMutableSet*)value;



- (CommentAudio*)primitiveAudio;
- (void)setPrimitiveAudio:(CommentAudio*)value;



- (NSMutableSet*)primitiveLinks;
- (void)setPrimitiveLinks:(NSMutableSet*)value;


@end
