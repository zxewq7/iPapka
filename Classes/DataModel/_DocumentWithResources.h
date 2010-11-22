// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentWithResources.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"

@class CommentAudio;
@class DocumentLink;








@class NSObject;


@class NSArray;

@interface DocumentWithResourcesID : NSManagedObjectID {}
@end

@interface _DocumentWithResources : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentWithResourcesID*)objectID;



@property (nonatomic, retain) NSString *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *createdStripped;

//- (BOOL)validateCreatedStripped:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *created;

//- (BOOL)validateCreated:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *modified;

//- (BOOL)validateModified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *priority;

@property short priorityValue;
- (short)priorityValue;
- (void)setPriorityValue:(short)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSObject *linksOrdering;

//- (BOOL)validateLinksOrdering:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *status;

@property short statusValue;
- (short)statusValue;
- (void)setStatusValue:(short)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *dateStripped;

//- (BOOL)validateDateStripped:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSArray *correspondents;

//- (BOOL)validateCorrespondents:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) CommentAudio* audio;
//- (BOOL)validateAudio:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* links;
- (NSMutableSet*)linksSet;



@end

@interface _DocumentWithResources (CoreDataGeneratedAccessors)

- (void)addLinks:(NSSet*)value_;
- (void)removeLinks:(NSSet*)value_;
- (void)addLinksObject:(DocumentLink*)value_;
- (void)removeLinksObject:(DocumentLink*)value_;

@end

@interface _DocumentWithResources (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAuthor;
- (void)setPrimitiveAuthor:(NSString*)value;


- (NSDate*)primitiveCreatedStripped;
- (void)setPrimitiveCreatedStripped:(NSDate*)value;


- (NSDate*)primitiveCreated;
- (void)setPrimitiveCreated:(NSDate*)value;


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;


- (NSDate*)primitiveModified;
- (void)setPrimitiveModified:(NSDate*)value;


- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;


- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (short)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(short)value_;


- (NSObject*)primitiveLinksOrdering;
- (void)setPrimitiveLinksOrdering:(NSObject*)value;


- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (short)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(short)value_;


- (NSDate*)primitiveDateStripped;
- (void)setPrimitiveDateStripped:(NSDate*)value;


- (NSArray*)primitiveCorrespondents;
- (void)setPrimitiveCorrespondents:(NSArray*)value;




- (CommentAudio*)primitiveAudio;
- (void)setPrimitiveAudio:(CommentAudio*)value;



- (NSMutableSet*)primitiveLinks;
- (void)setPrimitiveLinks:(NSMutableSet*)value;


@end
