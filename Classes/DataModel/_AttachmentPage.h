// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AttachmentPage.h instead.

#import <CoreData/CoreData.h>


@class Attachment;





@interface AttachmentPageID : NSManagedObjectID {}
@end

@interface _AttachmentPage : NSManagedObject {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AttachmentPageID*)objectID;



@property (nonatomic, retain) NSNumber *isFetched;

@property BOOL isFetchedValue;
- (BOOL)isFetchedValue;
- (void)setIsFetchedValue:(BOOL)value_;

//- (BOOL)validateIsFetched:(id*)value_ error:(NSError**)error_;



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




@property (nonatomic, retain) Attachment* attachment;
//- (BOOL)validateAttachment:(id*)value_ error:(NSError**)error_;



@end

@interface _AttachmentPage (CoreDataGeneratedAccessors)

@end

@interface _AttachmentPage (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsFetched;
- (void)setPrimitiveIsFetched:(NSNumber*)value;

- (BOOL)primitiveIsFetchedValue;
- (void)setPrimitiveIsFetchedValue:(BOOL)value_;


- (NSNumber*)primitiveNumber;
- (void)setPrimitiveNumber:(NSNumber*)value;

- (short)primitiveNumberValue;
- (void)setPrimitiveNumberValue:(short)value_;


- (NSNumber*)primitiveAngle;
- (void)setPrimitiveAngle:(NSNumber*)value;

- (float)primitiveAngleValue;
- (void)setPrimitiveAngleValue:(float)value_;




- (Attachment*)primitiveAttachment;
- (void)setPrimitiveAttachment:(Attachment*)value;


@end