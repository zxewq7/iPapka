// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SignatureAudio.h instead.

#import <CoreData/CoreData.h>
#import "FileField.h"

@class DocumentSignature;


@interface SignatureAudioID : NSManagedObjectID {}
@end

@interface _SignatureAudio : FileField {}

	
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SignatureAudioID*)objectID;




@property (nonatomic, retain) DocumentSignature* parent;
//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;



@end

@interface _SignatureAudio (CoreDataGeneratedAccessors)

@end

@interface _SignatureAudio (CoreDataGeneratedPrimitiveAccessors)



- (DocumentSignature*)primitiveParent;
- (void)setPrimitiveParent:(DocumentSignature*)value;


@end
