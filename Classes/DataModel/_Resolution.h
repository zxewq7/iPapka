// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Resolution.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"

@class Person;
@class Resolution;





@interface ResolutionID : NSManagedObjectID {}
@end

@interface _Resolution : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ResolutionID*)objectID;



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



@property (nonatomic, retain) Resolution* parentResolution;
//- (BOOL)validateParentResolution:(id*)value_ error:(NSError**)error_;



@end

@interface _Resolution (CoreDataGeneratedAccessors)

- (void)addPerformers:(NSSet*)value_;
- (void)removePerformers:(NSSet*)value_;
- (void)addPerformersObject:(Person*)value_;
- (void)removePerformersObject:(Person*)value_;

@end

@interface _Resolution (CoreDataGeneratedPrimitiveAccessors)

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



- (Resolution*)primitiveParentResolution;
- (void)setPrimitiveParentResolution:(Resolution*)value;


@end
