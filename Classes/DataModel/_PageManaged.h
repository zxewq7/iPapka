// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PageManaged.h instead.

#import <CoreData/CoreData.h>


@class AttachmentManaged;





@interface PageManagedID : NSManagedObjectID {}
@end

@interface _PageManaged : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PageManagedID*)objectID;



@property (nonatomic, retain) NSNumber *syncStatus;

@property short syncStatusValue;
- (short)syncStatusValue;
- (void)setSyncStatusValue:(short)value_;

//- (BOOL)validateSyncStatus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *number;

@property short numberValue;
- (short)numberValue;
- (void)setNumberValue:(short)value_;

//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *angle;

@property float angleValue;
- (float)angleValue;
- (void)setAngleValue:(float)value_;

//- (BOOL)validateAngle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) AttachmentManaged* attachment;
//- (BOOL)validateAttachment:(id*)value_ error:(NSError**)error_;



@end

@interface _PageManaged (CoreDataGeneratedAccessors)

@end

@interface _PageManaged (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveSyncStatus;
- (void)setPrimitiveSyncStatus:(NSNumber*)value;

- (short)primitiveSyncStatusValue;
- (void)setPrimitiveSyncStatusValue:(short)value_;


- (NSNumber*)primitiveNumber;
- (void)setPrimitiveNumber:(NSNumber*)value;

- (short)primitiveNumberValue;
- (void)setPrimitiveNumberValue:(short)value_;


- (NSNumber*)primitiveAngle;
- (void)setPrimitiveAngle:(NSNumber*)value;

- (float)primitiveAngleValue;
- (void)setPrimitiveAngleValue:(float)value_;




- (AttachmentManaged*)primitiveAttachment;
- (void)setPrimitiveAttachment:(AttachmentManaged*)value;


@end