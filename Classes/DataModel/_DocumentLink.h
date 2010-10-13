// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentLink.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"

@class Document;



@interface DocumentLinkID : NSManagedObjectID {}
@end

@interface _DocumentLink : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentLinkID*)objectID;



@property (nonatomic, retain) NSNumber *index;

@property short indexValue;
- (short)indexValue;
- (void)setIndexValue:(short)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Document* document;
//- (BOOL)validateDocument:(id*)value_ error:(NSError**)error_;



@end

@interface _DocumentLink (CoreDataGeneratedAccessors)

@end

@interface _DocumentLink (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber*)value;

- (short)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(short)value_;




- (Document*)primitiveDocument;
- (void)setPrimitiveDocument:(Document*)value;


@end
