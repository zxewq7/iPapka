// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentResolutionParent.h instead.

#import <CoreData/CoreData.h>
#import "BWOrderedManagedObject.h"

@class DocumentResolution;


@class NSArray;





@interface DocumentResolutionParentID : NSManagedObjectID {}
@end

@interface _DocumentResolutionParent : BWOrderedManagedObject {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentResolutionParentID*)objectID;



@property (nonatomic, retain) NSString *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSArray *performers;

//- (BOOL)validatePerformers:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isManaged;

@property BOOL isManagedValue;
- (BOOL)isManagedValue;
- (void)setIsManagedValue:(BOOL)value_;

//- (BOOL)validateIsManaged:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *deadline;

//- (BOOL)validateDeadline:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) DocumentResolution* resolution;
//- (BOOL)validateResolution:(id*)value_ error:(NSError**)error_;



@end

@interface _DocumentResolutionParent (CoreDataGeneratedAccessors)

@end

@interface _DocumentResolutionParent (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAuthor;
- (void)setPrimitiveAuthor:(NSString*)value;


- (NSArray*)primitivePerformers;
- (void)setPrimitivePerformers:(NSArray*)value;


- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;


- (NSNumber*)primitiveIsManaged;
- (void)setPrimitiveIsManaged:(NSNumber*)value;

- (BOOL)primitiveIsManagedValue;
- (void)setPrimitiveIsManagedValue:(BOOL)value_;


- (NSDate*)primitiveDeadline;
- (void)setPrimitiveDeadline:(NSDate*)value;


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (DocumentResolution*)primitiveResolution;
- (void)setPrimitiveResolution:(DocumentResolution*)value;


@end
