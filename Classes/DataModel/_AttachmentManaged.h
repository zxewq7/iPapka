// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AttachmentManaged.h instead.

#import <CoreData/CoreData.h>


@class DocumentManaged;
@class PageManaged;





@interface AttachmentManagedID : NSManagedObjectID {}
@end

@interface _AttachmentManaged : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AttachmentManagedID*)objectID;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isFetched;

@property BOOL isFetchedValue;
- (BOOL)isFetchedValue;
- (void)setIsFetchedValue:(BOOL)value_;

//- (BOOL)validateIsFetched:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) DocumentManaged* document;
//- (BOOL)validateDocument:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* pages;
- (NSMutableSet*)pagesSet;



@end

@interface _AttachmentManaged (CoreDataGeneratedAccessors)

- (void)addPages:(NSSet*)value_;
- (void)removePages:(NSSet*)value_;
- (void)addPagesObject:(PageManaged*)value_;
- (void)removePagesObject:(PageManaged*)value_;

@end

@interface _AttachmentManaged (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;


- (NSNumber*)primitiveIsFetched;
- (void)setPrimitiveIsFetched:(NSNumber*)value;

- (BOOL)primitiveIsFetchedValue;
- (void)setPrimitiveIsFetchedValue:(BOOL)value_;




- (DocumentManaged*)primitiveDocument;
- (void)setPrimitiveDocument:(DocumentManaged*)value;



- (NSMutableSet*)primitivePages;
- (void)setPrimitivePages:(NSMutableSet*)value;


@end
