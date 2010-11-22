// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Document.h instead.

#import <CoreData/CoreData.h>
#import "BWOrderedManagedObject.h"

@class Attachment;



@class NSObject;







@interface DocumentID : NSManagedObjectID {}
@end

@interface _Document : BWOrderedManagedObject {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentID*)objectID;



@property (nonatomic, retain) NSNumber *isEditable;

@property BOOL isEditableValue;
- (BOOL)isEditableValue;
- (void)setIsEditableValue:(BOOL)value_;

//- (BOOL)validateIsEditable:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *contentVersion;

//- (BOOL)validateContentVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *attachmentsOrdering;

//- (BOOL)validateAttachmentsOrdering:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *syncStatus;

@property short syncStatusValue;
- (short)syncStatusValue;
- (void)setSyncStatusValue:(short)value_;

//- (BOOL)validateSyncStatus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isRead;

@property BOOL isReadValue;
- (BOOL)isReadValue;
- (void)setIsReadValue:(BOOL)value_;

//- (BOOL)validateIsRead:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *docVersion;

//- (BOOL)validateDocVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* attachments;
- (NSMutableSet*)attachmentsSet;



@end

@interface _Document (CoreDataGeneratedAccessors)

- (void)addAttachments:(NSSet*)value_;
- (void)removeAttachments:(NSSet*)value_;
- (void)addAttachmentsObject:(Attachment*)value_;
- (void)removeAttachmentsObject:(Attachment*)value_;

@end

@interface _Document (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsEditable;
- (void)setPrimitiveIsEditable:(NSNumber*)value;

- (BOOL)primitiveIsEditableValue;
- (void)setPrimitiveIsEditableValue:(BOOL)value_;


- (NSString*)primitiveContentVersion;
- (void)setPrimitiveContentVersion:(NSString*)value;


- (NSObject*)primitiveAttachmentsOrdering;
- (void)setPrimitiveAttachmentsOrdering:(NSObject*)value;


- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSNumber*)primitiveSyncStatus;
- (void)setPrimitiveSyncStatus:(NSNumber*)value;

- (short)primitiveSyncStatusValue;
- (void)setPrimitiveSyncStatusValue:(short)value_;


- (NSNumber*)primitiveIsRead;
- (void)setPrimitiveIsRead:(NSNumber*)value;

- (BOOL)primitiveIsReadValue;
- (void)setPrimitiveIsReadValue:(BOOL)value_;


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;


- (NSString*)primitiveDocVersion;
- (void)setPrimitiveDocVersion:(NSString*)value;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSMutableSet*)primitiveAttachments;
- (void)setPrimitiveAttachments:(NSMutableSet*)value;


@end
