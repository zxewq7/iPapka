// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentSignature.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"


@class NSArray;

@interface DocumentSignatureID : NSManagedObjectID {}
@end

@interface _DocumentSignature : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentSignatureID*)objectID;



@property (nonatomic, retain) NSArray *correspondents;

//- (BOOL)validateCorrespondents:(id*)value_ error:(NSError**)error_;




@end

@interface _DocumentSignature (CoreDataGeneratedAccessors)

@end

@interface _DocumentSignature (CoreDataGeneratedPrimitiveAccessors)

- (NSArray*)primitiveCorrespondents;
- (void)setPrimitiveCorrespondents:(NSArray*)value;



@end
