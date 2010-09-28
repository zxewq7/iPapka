// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ResolutionManaged.h instead.

#import <CoreData/CoreData.h>
#import "DocumentManaged.h"

@class PersonManaged;



@interface ResolutionManagedID : NSManagedObjectID {}
@end

@interface _ResolutionManaged : DocumentManaged {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ResolutionManagedID*)objectID;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* performers;
- (NSMutableSet*)performersSet;



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




- (NSMutableSet*)primitivePerformers;
- (void)setPrimitivePerformers:(NSMutableSet*)value;


@end
