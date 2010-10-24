// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Document.h instead.

#import <CoreData/CoreData.h>
#import "BWOrderedManagedObject.h"

@class Attachment;
@class Comment;
@class DocumentLink;













@class NSArray;


@interface DocumentID : NSManagedObjectID {}
@end

@interface _Document : BWOrderedManagedObject {}

@property (nonatomic, readonly) NSArray *linksOrdered;

@property (nonatomic, readonly) NSArray *attachmentsOrdered;

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentID*)objectID;



@property (nonatomic, retain) NSNumber *priority;

@property short priorityValue;
- (short)priorityValue;
- (void)setPriorityValue:(short)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *registrationNumber;

//- (BOOL)validateRegistrationNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *dateModified;

//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *syncStatus;

@property short syncStatusValue;
- (short)syncStatusValue;
- (void)setSyncStatusValue:(short)value_;

//- (BOOL)validateSyncStatus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *registrationDate;

//- (BOOL)validateRegistrationDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *version;

//- (BOOL)validateVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *registrationDateStripped;

//- (BOOL)validateRegistrationDateStripped:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isRead;

@property BOOL isReadValue;
- (BOOL)isReadValue;
- (void)setIsReadValue:(BOOL)value_;

//- (BOOL)validateIsRead:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSArray *correspondents;

//- (BOOL)validateCorrespondents:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *status;

@property short statusValue;
- (short)statusValue;
- (void)setStatusValue:(short)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* attachments;
- (NSMutableSet*)attachmentsSet;



@property (nonatomic, retain) Comment* comment;
//- (BOOL)validateComment:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* links;
- (NSMutableSet*)linksSet;



@end

@interface _Document (CoreDataGeneratedAccessors)

- (void)addAttachments:(NSSet*)value_;
- (void)removeAttachments:(NSSet*)value_;
- (void)addAttachmentsObject:(Attachment*)value_;
- (void)removeAttachmentsObject:(Attachment*)value_;

- (void)addLinks:(NSSet*)value_;
- (void)removeLinks:(NSSet*)value_;
- (void)addLinksObject:(DocumentLink*)value_;
- (void)removeLinksObject:(DocumentLink*)value_;

@end

@interface _Document (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (short)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(short)value_;


- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;


- (NSString*)primitiveRegistrationNumber;
- (void)setPrimitiveRegistrationNumber:(NSString*)value;


- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;


- (NSNumber*)primitiveSyncStatus;
- (void)setPrimitiveSyncStatus:(NSNumber*)value;

- (short)primitiveSyncStatusValue;
- (void)setPrimitiveSyncStatusValue:(short)value_;


- (NSDate*)primitiveRegistrationDate;
- (void)setPrimitiveRegistrationDate:(NSDate*)value;


- (NSString*)primitiveVersion;
- (void)setPrimitiveVersion:(NSString*)value;


- (NSDate*)primitiveRegistrationDateStripped;
- (void)setPrimitiveRegistrationDateStripped:(NSDate*)value;


- (NSString*)primitiveAuthor;
- (void)setPrimitiveAuthor:(NSString*)value;


- (NSNumber*)primitiveIsRead;
- (void)setPrimitiveIsRead:(NSNumber*)value;

- (BOOL)primitiveIsReadValue;
- (void)setPrimitiveIsReadValue:(BOOL)value_;


- (NSArray*)primitiveCorrespondents;
- (void)setPrimitiveCorrespondents:(NSArray*)value;


- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (short)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(short)value_;




- (NSMutableSet*)primitiveAttachments;
- (void)setPrimitiveAttachments:(NSMutableSet*)value;



- (Comment*)primitiveComment;
- (void)setPrimitiveComment:(Comment*)value;



- (NSMutableSet*)primitiveLinks;
- (void)setPrimitiveLinks:(NSMutableSet*)value;


@end
