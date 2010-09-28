// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentManaged.h instead.

#import <CoreData/CoreData.h>


@class PersonManaged;













@interface DocumentManagedID : NSManagedObjectID {}
@end

@interface _DocumentManaged : NSManagedObject {}
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



@property (nonatomic, retain) NSNumber *isEditable;

@property BOOL isEditableValue;
- (BOOL)isEditableValue;
- (void)setIsEditableValue:(BOOL)value_;

//- (BOOL)validateIsEditable:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isRead;

@property BOOL isReadValue;
- (BOOL)isReadValue;
- (void)setIsReadValue:(BOOL)value_;

//- (BOOL)validateIsRead:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *dataSourceId;

//- (BOOL)validateDataSourceId:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isArchived;

@property BOOL isArchivedValue;
- (BOOL)isArchivedValue;
- (void)setIsArchivedValue:(BOOL)value_;

//- (BOOL)validateIsArchived:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *dateModified;

//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isDeclined;

@property BOOL isDeclinedValue;
- (BOOL)isDeclinedValue;
- (void)setIsDeclinedValue:(BOOL)value_;

//- (BOOL)validateIsDeclined:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isAccepted;

@property BOOL isAcceptedValue;
- (BOOL)isAcceptedValue;
- (void)setIsAcceptedValue:(BOOL)value_;

//- (BOOL)validateIsAccepted:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isSynced;

@property BOOL isSyncedValue;
- (BOOL)isSyncedValue;
- (void)setIsSyncedValue:(BOOL)value_;

//- (BOOL)validateIsSynced:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PersonManaged* author;
//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;



@end

@interface _DocumentManaged (CoreDataGeneratedAccessors)

@end

@interface _DocumentManaged (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsModified;
- (void)setPrimitiveIsModified:(NSNumber*)value;

- (BOOL)primitiveIsModifiedValue;
- (void)setPrimitiveIsModifiedValue:(BOOL)value_;


- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSNumber*)primitiveIsEditable;
- (void)setPrimitiveIsEditable:(NSNumber*)value;

- (BOOL)primitiveIsEditableValue;
- (void)setPrimitiveIsEditableValue:(BOOL)value_;


- (NSNumber*)primitiveIsRead;
- (void)setPrimitiveIsRead:(NSNumber*)value;

- (BOOL)primitiveIsReadValue;
- (void)setPrimitiveIsReadValue:(BOOL)value_;


- (NSString*)primitiveDataSourceId;
- (void)setPrimitiveDataSourceId:(NSString*)value;


- (NSNumber*)primitiveIsArchived;
- (void)setPrimitiveIsArchived:(NSNumber*)value;

- (BOOL)primitiveIsArchivedValue;
- (void)setPrimitiveIsArchivedValue:(BOOL)value_;


- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;


- (NSNumber*)primitiveIsDeclined;
- (void)setPrimitiveIsDeclined:(NSNumber*)value;

- (BOOL)primitiveIsDeclinedValue;
- (void)setPrimitiveIsDeclinedValue:(BOOL)value_;


- (NSNumber*)primitiveIsAccepted;
- (void)setPrimitiveIsAccepted:(NSNumber*)value;

- (BOOL)primitiveIsAcceptedValue;
- (void)setPrimitiveIsAcceptedValue:(BOOL)value_;


- (NSNumber*)primitiveIsSynced;
- (void)setPrimitiveIsSynced:(NSNumber*)value;

- (BOOL)primitiveIsSyncedValue;
- (void)setPrimitiveIsSyncedValue:(BOOL)value_;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (PersonManaged*)primitiveAuthor;
- (void)setPrimitiveAuthor:(PersonManaged*)value;


@end
