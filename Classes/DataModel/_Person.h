// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.h instead.

#import <CoreData/CoreData.h>


@class DocumentResolution;
@class Document;






@interface PersonID : NSManagedObjectID {}
@end

@interface _Person : NSManagedObject {}

	
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



@property (nonatomic, retain) NSSet* documents;
- (NSMutableSet*)documentsSet;



@end

@interface _Person (CoreDataGeneratedAccessors)

- (void)addResolutions:(NSSet*)value_;
- (void)removeResolutions:(NSSet*)value_;
- (void)addResolutionsObject:(DocumentResolution*)value_;
- (void)removeResolutionsObject:(DocumentResolution*)value_;

- (void)addDocuments:(NSSet*)value_;
- (void)removeDocuments:(NSSet*)value_;
- (void)addDocumentsObject:(Document*)value_;
- (void)removeDocumentsObject:(Document*)value_;

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



- (NSMutableSet*)primitiveDocuments;
- (void)setPrimitiveDocuments:(NSMutableSet*)value;


@end
