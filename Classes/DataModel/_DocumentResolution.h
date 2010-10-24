// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolution.h instead.

#import <CoreData/CoreData.h>
#import "DocumentResolutionAbstract.h"

@class Person;
@class DocumentResolutionParent;

@class NSObject;

@interface DocumentResolutionID : NSManagedObjectID {}
@end

@interface _DocumentResolution : DocumentResolutionAbstract {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentResolutionID*)objectID;



@property (nonatomic, retain) NSObject *performersOrdering;

//- (BOOL)validatePerformersOrdering:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* performers;
- (NSMutableSet*)performersSet;



@property (nonatomic, retain) DocumentResolutionParent* parentResolution;
//- (BOOL)validateParentResolution:(id*)value_ error:(NSError**)error_;



@end

@interface _DocumentResolution (CoreDataGeneratedAccessors)

- (void)addPerformers:(NSSet*)value_;
- (void)removePerformers:(NSSet*)value_;
- (void)addPerformersObject:(Person*)value_;
- (void)removePerformersObject:(Person*)value_;

@end

@interface _DocumentResolution (CoreDataGeneratedPrimitiveAccessors)

- (NSObject*)primitivePerformersOrdering;
- (void)setPrimitivePerformersOrdering:(NSObject*)value;




- (NSMutableSet*)primitivePerformers;
- (void)setPrimitivePerformers:(NSMutableSet*)value;



- (DocumentResolutionParent*)primitiveParentResolution;
- (void)setPrimitiveParentResolution:(DocumentResolutionParent*)value;


@end
