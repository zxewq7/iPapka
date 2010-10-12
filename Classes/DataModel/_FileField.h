// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FileField.h instead.

#import <CoreData/CoreData.h>











@interface FileFieldID : NSManagedObjectID {}
@end

@interface _FileField : NSManagedObject {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FileFieldID*)objectID;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *syncStatus;

@property short syncStatusValue;
- (short)syncStatusValue;
- (void)setSyncStatusValue:(short)value_;

//- (BOOL)validateSyncStatus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *dateModified;

//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *version;

//- (BOOL)validateVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *url;

//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;




@end

@interface _FileField (CoreDataGeneratedAccessors)

@end

@interface _FileField (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;


- (NSNumber*)primitiveSyncStatus;
- (void)setPrimitiveSyncStatus:(NSNumber*)value;

- (short)primitiveSyncStatusValue;
- (void)setPrimitiveSyncStatusValue:(short)value_;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;


- (NSString*)primitiveVersion;
- (void)setPrimitiveVersion:(NSString*)value;


- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;



@end
