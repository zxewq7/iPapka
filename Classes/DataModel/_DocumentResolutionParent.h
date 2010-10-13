// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolutionParent.h instead.

#import <CoreData/CoreData.h>
#import "DocumentResolutionAbstract.h"

@class DocumentResolution;

@class NSArray;

@interface DocumentResolutionParentID : NSManagedObjectID {}
@end

@interface _DocumentResolutionParent : DocumentResolutionAbstract {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentResolutionParentID*)objectID;



@property (nonatomic, retain) NSArray *performers;

//- (BOOL)validatePerformers:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) DocumentResolution* resolution;
//- (BOOL)validateResolution:(id*)value_ error:(NSError**)error_;



@end

@interface _DocumentResolutionParent (CoreDataGeneratedAccessors)

@end

@interface _DocumentResolutionParent (CoreDataGeneratedPrimitiveAccessors)

- (NSArray*)primitivePerformers;
- (void)setPrimitivePerformers:(NSArray*)value;




- (DocumentResolution*)primitiveResolution;
- (void)setPrimitiveResolution:(DocumentResolution*)value;


@end
