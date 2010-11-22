// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentLink.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"

@class DocumentWithResources;



@interface DocumentLinkID : NSManagedObjectID {}
@end

@interface _DocumentLink : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentLinkID*)objectID;



@property (nonatomic, retain) NSString *index;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) DocumentWithResources* document;
//- (BOOL)validateDocument:(id*)value_ error:(NSError**)error_;



@end

@interface _DocumentLink (CoreDataGeneratedAccessors)

@end

@interface _DocumentLink (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveIndex;
- (void)setPrimitiveIndex:(NSString*)value;




- (DocumentWithResources*)primitiveDocument;
- (void)setPrimitiveDocument:(DocumentWithResources*)value;


@end
