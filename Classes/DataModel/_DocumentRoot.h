// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentRoot.h instead.

#import <CoreData/CoreData.h>
#import "DocumentWithResources.h"
















@class NSArray;

@interface DocumentRootID : NSManagedObjectID {}
@end

@interface _DocumentRoot : DocumentWithResources {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentRootID*)objectID;



@property (nonatomic, retain) NSString *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *receivedStripped;

//- (BOOL)validateReceivedStripped:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *docVersion;

//- (BOOL)validateDocVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *modified;

//- (BOOL)validateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *received;

//- (BOOL)validateReceived:(id*)value_ error:(NSError**)error_;



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

@interface _DocumentRoot (CoreDataGeneratedAccessors)

@end

@interface _DocumentRoot (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAuthor;
- (void)setPrimitiveAuthor:(NSString*)value;


- (NSDate*)primitiveReceivedStripped;
- (void)setPrimitiveReceivedStripped:(NSDate*)value;


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;


- (NSString*)primitiveDocVersion;
- (void)setPrimitiveDocVersion:(NSString*)value;


- (NSDate*)primitiveModified;
- (void)setPrimitiveModified:(NSDate*)value;


- (NSDate*)primitiveReceived;
- (void)setPrimitiveReceived:(NSDate*)value;


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
