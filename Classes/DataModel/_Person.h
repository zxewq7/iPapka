// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.h instead.

#import <CoreData/CoreData.h>
#import "BWOrderedManagedObject.h"

@class DocumentResolution;






@interface PersonID : NSManagedObjectID {}
@end

@interface _Person : BWOrderedManagedObject {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PersonID*)objectID;



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

@interface _Person (CoreDataGeneratedAccessors)

- (void)addResolutions:(NSSet*)value_;
- (void)removeResolutions:(NSSet*)value_;
- (void)addResolutionsObject:(DocumentResolution*)value_;
- (void)removeResolutionsObject:(DocumentResolution*)value_;

@end

@interface _Person (CoreDataGeneratedPrimitiveAccessors)

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
