// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolutionAbstract.h instead.

#import <CoreData/CoreData.h>
#import "DocumentWithResources.h"







@interface DocumentResolutionAbstractID : NSManagedObjectID {}
@end

@interface _DocumentResolutionAbstract : DocumentWithResources {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentResolutionAbstractID*)objectID;



@property (nonatomic, retain) NSDate *regDate;

//- (BOOL)validateRegDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isManaged;

@property BOOL isManagedValue;
- (BOOL)isManagedValue;
- (void)setIsManagedValue:(BOOL)value_;

//- (BOOL)validateIsManaged:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *regNumber;

//- (BOOL)validateRegNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *deadline;

//- (BOOL)validateDeadline:(id*)value_ error:(NSError**)error_;




@end

@interface _DocumentResolutionAbstract (CoreDataGeneratedAccessors)

@end

@interface _DocumentResolutionAbstract (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveRegDate;
- (void)setPrimitiveRegDate:(NSDate*)value;


- (NSNumber*)primitiveIsManaged;
- (void)setPrimitiveIsManaged:(NSNumber*)value;

- (BOOL)primitiveIsManagedValue;
- (void)setPrimitiveIsManagedValue:(BOOL)value_;


- (NSString*)primitiveRegNumber;
- (void)setPrimitiveRegNumber:(NSString*)value;


- (NSDate*)primitiveDeadline;
- (void)setPrimitiveDeadline:(NSDate*)value;



@end
