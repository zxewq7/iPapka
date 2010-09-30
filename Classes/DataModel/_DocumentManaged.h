// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentManaged.h instead.

#import <CoreData/CoreData.h>


@class DocumentManaged;
@class PersonManaged;
@class DocumentManaged;
@class AttachmentManaged;












@interface DocumentManagedID : NSManagedObjectID {}
@end

@interface _DocumentManaged : NSManagedObject {}

@property (nonatomic, readonly) NSArray *linksOrdered;

@property (nonatomic, readonly) NSArray *attachmentsOrdered;

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentManagedID*)objectID;



@property (nonatomic, retain) NSNumber *isModified;

@property BOOL isModifiedValue;
- (BOOL)isModifiedValue;
- (void)setIsModifiedValue:(BOOL)value_;

//- (BOOL)validateIsModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isEditable;

@property BOOL isEditableValue;
- (BOOL)isEditableValue;
- (void)setIsEditableValue:(BOOL)value_;

//- (BOOL)validateIsEditable:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *strippedDateModified;

//- (BOOL)validateStrippedDateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isRead;

@property BOOL isReadValue;
- (BOOL)isReadValue;
- (void)setIsReadValue:(BOOL)value_;

//- (BOOL)validateIsRead:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *dateModified;

//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *status;

@property short statusValue;
- (short)statusValue;
- (void)setStatusValue:(short)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isSynced;

@property BOOL isSyncedValue;
- (BOOL)isSyncedValue;
- (void)setIsSyncedValue:(BOOL)value_;

//- (BOOL)validateIsSynced:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* links;
- (NSMutableSet*)linksSet;



@property (nonatomic, retain) PersonManaged* author;
//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) DocumentManaged* parent;
//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* attachments;
- (NSMutableSet*)attachmentsSet;



@end

@interface _DocumentManaged (CoreDataGeneratedAccessors)

- (void)addLinks:(NSSet*)value_;
- (void)removeLinks:(NSSet*)value_;
- (void)addLinksObject:(DocumentManaged*)value_;
- (void)removeLinksObject:(DocumentManaged*)value_;

- (void)addAttachments:(NSSet*)value_;
- (void)removeAttachments:(NSSet*)value_;
- (void)addAttachmentsObject:(AttachmentManaged*)value_;
- (void)removeAttachmentsObject:(AttachmentManaged*)value_;

@end

@interface _DocumentManaged (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsModified;
- (void)setPrimitiveIsModified:(NSNumber*)value;

- (BOOL)primitiveIsModifiedValue;
- (void)setPrimitiveIsModifiedValue:(BOOL)value_;


- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;


- (NSNumber*)primitiveIsEditable;
- (void)setPrimitiveIsEditable:(NSNumber*)value;

- (BOOL)primitiveIsEditableValue;
- (void)setPrimitiveIsEditableValue:(BOOL)value_;


- (NSDate*)primitiveStrippedDateModified;
- (void)setPrimitiveStrippedDateModified:(NSDate*)value;


- (NSNumber*)primitiveIsRead;
- (void)setPrimitiveIsRead:(NSNumber*)value;

- (BOOL)primitiveIsReadValue;
- (void)setPrimitiveIsReadValue:(BOOL)value_;


- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;


- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (short)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(short)value_;


- (NSNumber*)primitiveIsSynced;
- (void)setPrimitiveIsSynced:(NSNumber*)value;

- (BOOL)primitiveIsSyncedValue;
- (void)setPrimitiveIsSyncedValue:(BOOL)value_;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSMutableSet*)primitiveLinks;
- (void)setPrimitiveLinks:(NSMutableSet*)value;



- (PersonManaged*)primitiveAuthor;
- (void)setPrimitiveAuthor:(PersonManaged*)value;



- (DocumentManaged*)primitiveParent;
- (void)setPrimitiveParent:(DocumentManaged*)value;



- (NSMutableSet*)primitiveAttachments;
- (void)setPrimitiveAttachments:(NSMutableSet*)value;


@end
