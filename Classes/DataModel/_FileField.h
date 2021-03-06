// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FileField.h instead.

#import <CoreData/CoreData.h>
#import "BWOrderedManagedObject.h"








@interface FileFieldID : NSManagedObjectID {}
@end

@interface _FileField : BWOrderedManagedObject {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FileFieldID*)objectID;



@property (nonatomic, retain) NSDate *modified;

//- (BOOL)validateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *url;

//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *syncStatus;

@property short syncStatusValue;
- (short)syncStatusValue;
- (void)setSyncStatusValue:(short)value_;

//- (BOOL)validateSyncStatus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *version;

//- (BOOL)validateVersion:(id*)value_ error:(NSError**)error_;




@end

@interface _FileField (CoreDataGeneratedAccessors)

@end

@interface _FileField (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveModified;
- (void)setPrimitiveModified:(NSDate*)value;


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;


- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;


- (NSNumber*)primitiveSyncStatus;
- (void)setPrimitiveSyncStatus:(NSNumber*)value;

- (short)primitiveSyncStatusValue;
- (void)setPrimitiveSyncStatusValue:(short)value_;


- (NSString*)primitiveVersion;
- (void)setPrimitiveVersion:(NSString*)value;



@end
