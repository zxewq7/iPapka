// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolutionAbstract.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"





@interface DocumentResolutionAbstractID : NSManagedObjectID {}
@end

@interface _DocumentResolutionAbstract : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentResolutionAbstractID*)objectID;



@property (nonatomic, retain) NSNumber *isManaged;

@property BOOL isManagedValue;
- (BOOL)isManagedValue;
- (void)setIsManagedValue:(BOOL)value_;

//- (BOOL)validateIsManaged:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *deadline;

//- (BOOL)validateDeadline:(id*)value_ error:(NSError**)error_;




@end

@interface _DocumentResolutionAbstract (CoreDataGeneratedAccessors)

@end

@interface _DocumentResolutionAbstract (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsManaged;
- (void)setPrimitiveIsManaged:(NSNumber*)value;

- (BOOL)primitiveIsManagedValue;
- (void)setPrimitiveIsManagedValue:(BOOL)value_;


- (NSDate*)primitiveDeadline;
- (void)setPrimitiveDeadline:(NSDate*)value;



@end
