// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ResolutionManaged.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"

@class PersonManaged;
@class ResolutionManaged;





@interface ResolutionManagedID : NSManagedObjectID {}
@end

@interface _ResolutionManaged : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ResolutionManagedID*)objectID;



@property (nonatomic, retain) NSNumber *isManaged;

@property BOOL isManagedValue;
- (BOOL)isManagedValue;
- (void)setIsManagedValue:(BOOL)value_;

//- (BOOL)validateIsManaged:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *deadline;

//- (BOOL)validateDeadline:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* performers;
- (NSMutableSet*)performersSet;



@property (nonatomic, retain) ResolutionManaged* parentResolution;
//- (BOOL)validateParentResolution:(id*)value_ error:(NSError**)error_;



@end

@interface _ResolutionManaged (CoreDataGeneratedAccessors)

- (void)addPerformers:(NSSet*)value_;
- (void)removePerformers:(NSSet*)value_;
- (void)addPerformersObject:(PersonManaged*)value_;
- (void)removePerformersObject:(PersonManaged*)value_;

@end

@interface _ResolutionManaged (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsManaged;
- (void)setPrimitiveIsManaged:(NSNumber*)value;

- (BOOL)primitiveIsManagedValue;
- (void)setPrimitiveIsManagedValue:(BOOL)value_;


- (NSDate*)primitiveDeadline;
- (void)setPrimitiveDeadline:(NSDate*)value;


- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;




- (NSMutableSet*)primitivePerformers;
- (void)setPrimitivePerformers:(NSMutableSet*)value;



- (ResolutionManaged*)primitiveParentResolution;
- (void)setPrimitiveParentResolution:(ResolutionManaged*)value;


@end
