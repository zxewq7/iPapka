// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ResolutionManaged.h instead.

#import <CoreData/CoreData.h>
#import "DocumentManaged.h"


@class NSObject;

@interface ResolutionManagedID : NSManagedObjectID {}
@end

@interface _ResolutionManaged : DocumentManaged {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ResolutionManagedID*)objectID;



@property (nonatomic, retain) NSObject *performers;

//- (BOOL)validatePerformers:(id*)value_ error:(NSError**)error_;




@end

@interface _ResolutionManaged (CoreDataGeneratedAccessors)

@end

@interface _ResolutionManaged (CoreDataGeneratedPrimitiveAccessors)

- (NSObject*)primitivePerformers;
- (void)setPrimitivePerformers:(NSObject*)value;



@end
