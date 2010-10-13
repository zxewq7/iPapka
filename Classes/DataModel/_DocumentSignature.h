// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocumentSignature.h instead.

#import <CoreData/CoreData.h>
#import "Document.h"




@interface DocumentSignatureID : NSManagedObjectID {}
@end

@interface _DocumentSignature : Document {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DocumentSignatureID*)objectID;



@property (nonatomic, retain) NSString *registrationNumber;

//- (BOOL)validateRegistrationNumber:(id*)value_ error:(NSError**)error_;




@end

@interface _DocumentSignature (CoreDataGeneratedAccessors)

@end

@interface _DocumentSignature (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveRegistrationNumber;
- (void)setPrimitiveRegistrationNumber:(NSString*)value;



@end
