// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PersonManaged.h instead.

#import <CoreData/CoreData.h>


@class ResolutionManaged;






@interface PersonManagedID : NSManagedObjectID {}
@end

@interface _PersonManaged : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PersonManagedID*)objectID;



@property (nonatomic, retain) NSString *first;

//- (BOOL)validateFirst:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *last;

//- (BOOL)validateLast:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *middle;

//- (BOOL)validateMiddle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* resolutions;
- (NSMutableSet*)resolutionsSet;



@end

@interface _PersonManaged (CoreDataGeneratedAccessors)

- (void)addResolutions:(NSSet*)value_;
- (void)removeResolutions:(NSSet*)value_;
- (void)addResolutionsObject:(ResolutionManaged*)value_;
- (void)removeResolutionsObject:(ResolutionManaged*)value_;

@end

@interface _PersonManaged (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFirst;
- (void)setPrimitiveFirst:(NSString*)value;


- (NSString*)primitiveLast;
- (void)setPrimitiveLast:(NSString*)value;


- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSString*)primitiveMiddle;
- (void)setPrimitiveMiddle:(NSString*)value;




- (NSMutableSet*)primitiveResolutions;
- (void)setPrimitiveResolutions:(NSMutableSet*)value;


@end