// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentManaged.h instead.

#import <CoreData/CoreData.h>












@interface DocumentManagedID : NSManagedObjectID {}
@end

@interface _DocumentManaged : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentManagedID*)objectID;



@property (nonatomic, retain) NSNumber *isEditable;

@property BOOL isEditableValue;
- (BOOL)isEditableValue;
- (void)setIsEditableValue:(BOOL)value_;

//- (BOOL)validateIsEditable:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *dataSourceId;

//- (BOOL)validateDataSourceId:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isArchived;

@property BOOL isArchivedValue;
- (BOOL)isArchivedValue;
- (void)setIsArchivedValue:(BOOL)value_;

//- (BOOL)validateIsArchived:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isRead;

@property BOOL isReadValue;
- (BOOL)isReadValue;
- (void)setIsReadValue:(BOOL)value_;

//- (BOOL)validateIsRead:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *dateModified;

//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@end

@interface _DocumentManaged (CoreDataGeneratedAccessors)

@end

@interface _DocumentManaged (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsEditable;
- (void)setPrimitiveIsEditable:(NSNumber*)value;

- (BOOL)primitiveIsEditableValue;
- (void)setPrimitiveIsEditableValue:(BOOL)value_;


- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSString*)primitiveDataSourceId;
- (void)setPrimitiveDataSourceId:(NSString*)value;


- (NSNumber*)primitiveIsArchived;
- (void)setPrimitiveIsArchived:(NSNumber*)value;

- (BOOL)primitiveIsArchivedValue;
- (void)setPrimitiveIsArchivedValue:(BOOL)value_;


- (NSString*)primitiveAuthor;
- (void)setPrimitiveAuthor:(NSString*)value;


- (NSNumber*)primitiveIsRead;
- (void)setPrimitiveIsRead:(NSNumber*)value;

- (BOOL)primitiveIsReadValue;
- (void)setPrimitiveIsReadValue:(BOOL)value_;


- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;



@end
