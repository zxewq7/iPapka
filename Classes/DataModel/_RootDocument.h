// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RootDocument.h instead.

#import <CoreData/CoreData.h>
#import "DocumentWithResources.h"
















@class NSArray;

@interface RootDocumentID : NSManagedObjectID {}
@end

@interface _RootDocument : DocumentWithResources {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RootDocumentID*)objectID;



@property (nonatomic, retain) NSString *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *createdStripped;

//- (BOOL)validateCreatedStripped:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *created;

//- (BOOL)validateCreated:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *docVersion;

//- (BOOL)validateDocVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *modified;

//- (BOOL)validateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isRead;

@property BOOL isReadValue;
- (BOOL)isReadValue;
- (void)setIsReadValue:(BOOL)value_;

//- (BOOL)validateIsRead:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *contentVersion;

//- (BOOL)validateContentVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *priority;

@property short priorityValue;
- (short)priorityValue;
- (void)setPriorityValue:(short)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *syncStatus;

@property short syncStatusValue;
- (short)syncStatusValue;
- (void)setSyncStatusValue:(short)value_;

//- (BOOL)validateSyncStatus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *status;

@property short statusValue;
- (short)statusValue;
- (void)setStatusValue:(short)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *dateStripped;

//- (BOOL)validateDateStripped:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSArray *correspondents;

//- (BOOL)validateCorrespondents:(id*)value_ error:(NSError**)error_;




@end

@interface _RootDocument (CoreDataGeneratedAccessors)

@end

@interface _RootDocument (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAuthor;
- (void)setPrimitiveAuthor:(NSString*)value;


- (NSDate*)primitiveCreatedStripped;
- (void)setPrimitiveCreatedStripped:(NSDate*)value;


- (NSDate*)primitiveCreated;
- (void)setPrimitiveCreated:(NSDate*)value;


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;


- (NSString*)primitiveDocVersion;
- (void)setPrimitiveDocVersion:(NSString*)value;


- (NSDate*)primitiveModified;
- (void)setPrimitiveModified:(NSDate*)value;


- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;


- (NSNumber*)primitiveIsRead;
- (void)setPrimitiveIsRead:(NSNumber*)value;

- (BOOL)primitiveIsReadValue;
- (void)setPrimitiveIsReadValue:(BOOL)value_;


- (NSString*)primitiveContentVersion;
- (void)setPrimitiveContentVersion:(NSString*)value;


- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (short)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(short)value_;


- (NSNumber*)primitiveSyncStatus;
- (void)setPrimitiveSyncStatus:(NSNumber*)value;

- (short)primitiveSyncStatusValue;
- (void)setPrimitiveSyncStatusValue:(short)value_;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;


- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (short)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(short)value_;


- (NSDate*)primitiveDateStripped;
- (void)setPrimitiveDateStripped:(NSDate*)value;


- (NSArray*)primitiveCorrespondents;
- (void)setPrimitiveCorrespondents:(NSArray*)value;



@end
