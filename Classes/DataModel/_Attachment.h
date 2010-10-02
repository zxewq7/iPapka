// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Attachment.h instead.

#import <CoreData/CoreData.h>


@class Document;
@class AttachmentPage;




@interface AttachmentID : NSManagedObjectID {}
@end

@interface _Attachment : NSManagedObject {}

@property (nonatomic, readonly) NSArray *pagesOrdered;

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AttachmentID*)objectID;



@property (nonatomic, retain) NSString *uid;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Document* document;
//- (BOOL)validateDocument:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* pages;
- (NSMutableSet*)pagesSet;



@end

@interface _Attachment (CoreDataGeneratedAccessors)

- (void)addPages:(NSSet*)value_;
- (void)removePages:(NSSet*)value_;
- (void)addPagesObject:(AttachmentPage*)value_;
- (void)removePagesObject:(AttachmentPage*)value_;

@end

@interface _Attachment (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (Document*)primitiveDocument;
- (void)setPrimitiveDocument:(Document*)value;



- (NSMutableSet*)primitivePages;
- (void)setPrimitivePages:(NSMutableSet*)value;


@end