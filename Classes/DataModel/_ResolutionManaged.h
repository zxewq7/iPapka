// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ResolutionManaged.h instead.

#import <CoreData/CoreData.h>
#import "DocumentManaged.h"

@class PersonManaged;
@class ResolutionManaged;




@interface ResolutionManagedID : NSManagedObjectID {}
@end

@interface _ResolutionManaged : DocumentManaged {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ResolutionManagedID*)objectID;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *deadline;

//- (BOOL)validateDeadline:(id*)value_ error:(NSError**)error_;




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

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;


- (NSDate*)primitiveDeadline;
- (void)setPrimitiveDeadline:(NSDate*)value;




- (NSMutableSet*)primitivePerformers;
- (void)setPrimitivePerformers:(NSMutableSet*)value;



- (ResolutionManaged*)primitiveParentResolution;
- (void)setPrimitiveParentResolution:(ResolutionManaged*)value;


@end
