// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolution.h instead.

#import <CoreData/CoreData.h>
#import "DocumentRoot.h"

@class Person;
@class DocumentResolutionParent;

@class NSObject;





@interface DocumentResolutionID : NSManagedObjectID {}
@end

@interface _DocumentResolution : DocumentRoot {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentResolutionID*)objectID;



@property (nonatomic, retain) NSObject *performersOrdering;

//- (BOOL)validatePerformersOrdering:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *regDate;

//- (BOOL)validateRegDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isManaged;

@property BOOL isManagedValue;
- (BOOL)isManagedValue;
- (void)setIsManagedValue:(BOOL)value_;

//- (BOOL)validateIsManaged:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *deadline;

//- (BOOL)validateDeadline:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *regNumber;

//- (BOOL)validateRegNumber:(id*)value_ error:(NSError**)error_;




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


- (NSDate*)primitiveRegDate;
- (void)setPrimitiveRegDate:(NSDate*)value;


- (NSNumber*)primitiveIsManaged;
- (void)setPrimitiveIsManaged:(NSNumber*)value;

- (BOOL)primitiveIsManagedValue;
- (void)setPrimitiveIsManagedValue:(BOOL)value_;


- (NSDate*)primitiveDeadline;
- (void)setPrimitiveDeadline:(NSDate*)value;


- (NSString*)primitiveRegNumber;
- (void)setPrimitiveRegNumber:(NSString*)value;




- (NSMutableSet*)primitivePerformers;
- (void)setPrimitivePerformers:(NSMutableSet*)value;



- (DocumentResolutionParent*)primitiveParentResolution;
- (void)setPrimitiveParentResolution:(DocumentResolutionParent*)value;


@end
