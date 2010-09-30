// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AttachmentManaged.h instead.

#import <CoreData/CoreData.h>


@class Document;
@class PageManaged;




@interface AttachmentManagedID : NSManagedObjectID {}
@end

@interface _AttachmentManaged : NSManagedObject {}

@property (nonatomic, readonly) NSArray *pagesOrdered;

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AttachmentManagedID*)objectID;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Document* document;
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




- (Document*)primitiveDocument;
- (void)setPrimitiveDocument:(Document*)value;



- (NSMutableSet*)primitivePages;
- (void)setPrimitivePages:(NSMutableSet*)value;


@end
